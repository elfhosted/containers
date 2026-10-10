#!/bin/bash
# Replaces upstream's runtime-entrypoint.sh + entrypoint.sh + supervisord. Runs
# entirely as the image user (568) with a read-only root filesystem: persistent
# state in /config, scratch in /tmp. tini (PID 1) runs this script, which starts
# the long-running processes and exits as soon as any one of them does, so the
# orchestrator restarts the container instead of it limping on half-alive.
#
# Kept from upstream, in the same order: the SQLite startup integrity check and
# its recovery page, the bounded migrate retry, the resource-tier sizing that
# decides which celery workers run, and the open-file limit fix for celery beat.
# Dropped: PUID/PGID remapping and every chown (ownership is baked into the
# image and the volume is mounted with fsGroup), the runtime collectstatic (done
# at build time; the rootfs is read-only), the configurable listener port, and
# supervisord.
set -euo pipefail

log() {
    echo "[elf-entrypoint] $*" >&2
}

cd /floppy

# Upstream bakes the build identity into this file so a stray VERSION in the
# environment cannot make the app misreport which build is running.
if [ -f /etc/floppy-build-info ]; then
    # shellcheck disable=SC1091
    . /etc/floppy-build-info
    export VERSION COMMIT_SHA
fi

# /floppy/db and /floppy/backups are build-time symlinks into /config. Upstream
# creates both lazily; create them here so the symlinks resolve on first boot.
mkdir -p /config/backups /config/logs

# SECRET signs sessions and CSRF tokens and encrypts stored provider
# credentials. Upstream only generates one when /.dockerenv exists, which it
# does not under Kubernetes, and otherwise refuses to start. Generate a random
# per-instance key once, at the same path upstream uses inside Docker
# (FLOPPY_DATA_DIR/secret_key), so an upstream db/ directory dropped into
# /config keeps its key.
if [ -z "${SECRET:-}" ] && [ -z "${SECRET_FILE:-}" ]; then
    secret_path=/config/secret_key
    if [ ! -s "${secret_path}" ]; then
        log "SECRET not set; generating a per-instance key at ${secret_path}"
        (umask 077 && python -c 'import secrets; print(secrets.token_urlsafe(50), end="")' > "${secret_path}.tmp")
        mv "${secret_path}.tmp" "${secret_path}"
    fi
    SECRET="$(cat "${secret_path}")"
    export SECRET
fi

log "Floppy runtime: version=${VERSION:-unknown} commit=${COMMIT_SHA:-unknown}"

db_file=/config/db.sqlite3

# Upstream's startup gate: check SQLite storage and relationships before
# migrating. On failure it parks: a recovery page is served on the app port
# (behind SSO, like the rest of the UI) and startup resumes only once a choice is
# submitted there. See src/config/sqlite_recovery_policy.py.
if [ -z "${DB_HOST:-}" ] && [ -f "${db_file}" ]; then
    while :; do
        log "Checking SQLite storage and relationships for ${db_file}"
        integrity_status=0
        python -m config.sqlite_startup_watchdog "${db_file}" \
            python -c 'from config.sqlite_recovery_policy import check_database_for_startup; import sys; check_database_for_startup(sys.argv[1])' \
            "${db_file}" || integrity_status=$?
        if [ "${integrity_status}" -eq 0 ]; then
            break
        fi
        log "SQLite startup is paused (check exited ${integrity_status}); migrations and services were not started"
        log "For a full diagnosis run: kubectl exec <pod> -c main -- python manage.py floppy_preflight"
        decision_file="${db_file}.integrity.decision"
        rm -f "${decision_file}"
        python -m config.sqlite_recovery_server "${db_file}" 8000 || true
        if [ ! -f "${decision_file}" ]; then
            # No choice was made; stay parked rather than spin.
            while :; do sleep 86400; done
        fi
    done
fi

# Upstream's bounded, retrying migrate: a blocked migration fails loudly and
# retries instead of wedging the container.
migrate_attempts=0
migrate_verbosity=1
until log "Applying database migrations (attempt $((migrate_attempts + 1)))" && \
      DB_POOL_ENABLED=false PGOPTIONS="-c lock_timeout=120s" \
      timeout 900 python manage.py migrate --noinput -v "${migrate_verbosity}"; do
    migrate_attempts=$((migrate_attempts + 1))
    migrate_verbosity=2
    if [ "${migrate_attempts}" -ge 5 ]; then
        log "Migrations failed after ${migrate_attempts} attempts, exiting"
        exit 1
    fi
    log "Migrations blocked or failed (attempt ${migrate_attempts}), retrying in 15s"
    sleep 15
done

# Probe the container's memory/CPU once and export the sizing decision (gunicorn
# threads, which celery workers run and which queues each consumes). Values set
# explicitly in the environment are echoed back untouched.
if resource_env=$(python -c 'from config.runtime_profile import emit_env; emit_env()'); then
    eval "${resource_env}"
else
    log "WARNING: resource detection failed; using built-in defaults"
fi
export FLOPPY_RESOURCE_TIER="${FLOPPY_RESOURCE_TIER:-standard}"
export FLOPPY_CELERY_QUEUES="${FLOPPY_CELERY_QUEUES:-celery}"
export FLOPPY_CELERY_ROLE="${FLOPPY_CELERY_ROLE:-background}"
export FLOPPY_START_INTERACTIVE_WORKER="${FLOPPY_START_INTERACTIVE_WORKER:-true}"
export FLOPPY_START_DISCOVER_WORKER="${FLOPPY_START_DISCOVER_WORKER:-true}"

# Read by `manage.py floppy_preflight` so it reports this boot's decision.
python -c 'import json, sys; from config.runtime_profile import sizing_report; sys.stdout.write(json.dumps(sizing_report()))' \
    > /tmp/floppy-boot-sizing.json 2>/dev/null || rm -f /tmp/floppy-boot-sizing.json

# Celery's embedded beat closes every descriptor up to RLIMIT_NOFILE on start;
# with an effectively unlimited limit that pins a core for hours before any
# scheduled task runs (celery/celery#8306). Lower the soft limit once, here.
nofile_soft="${FLOPPY_NOFILE_LIMIT:-65536}"
current_nofile="$(ulimit -n 2>/dev/null || echo unlimited)"
if [ "${current_nofile}" = "unlimited" ] || [ "${current_nofile}" -gt "${nofile_soft}" ] 2>/dev/null; then
    ulimit -n "${nofile_soft}" 2>/dev/null || \
        log "WARNING: open-file soft limit is ${current_nofile} and could not be lowered"
fi

mkdir -p /tmp/health_check_storage_test
mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi /tmp/nginx/scgi
if [ "${FLOPPY_IPV6_ENABLED:-${YAMTRACK_IPV6_ENABLED:-False}}" = "True" ]; then
    sed 's/listen 8000;/listen 8000; listen [::]:8000;/' /etc/nginx/floppy.conf > /tmp/nginx/nginx.conf
else
    cp /etc/nginx/floppy.conf /tmp/nginx/nginx.conf
fi

case "${DEBUG:-False}" in
    [Tt]rue|1|[Yy]es|[Oo]n) loglevel=DEBUG ;;
    *) loglevel=INFO ;;
esac

pids=()

log "Starting gunicorn on 127.0.0.1:8001"
gunicorn --control-socket /tmp/gunicorn.ctl --config python:config.gunicorn config.wsgi:application &
pids+=($!)

# The background worker carries the embedded beat (django-celery-beat's
# database scheduler, so no schedule file is written).
log "Starting celery background worker queues=${FLOPPY_CELERY_QUEUES} role=${FLOPPY_CELERY_ROLE}"
FLOPPY_PROCESS_ROLE="${FLOPPY_CELERY_ROLE}" \
    celery --app config worker --beat --scheduler django \
    --queues "${FLOPPY_CELERY_QUEUES}" --hostname 'celery@%h' \
    --loglevel "${loglevel}" --without-mingle --without-gossip &
pids+=($!)

if [ "${FLOPPY_START_INTERACTIVE_WORKER}" = "true" ]; then
    log "Starting celery interactive worker"
    FLOPPY_PROCESS_ROLE=interactive \
        celery --app config worker --queues interactive --hostname 'celery-interactive@%h' \
        --loglevel "${loglevel}" --without-mingle --without-gossip &
    pids+=($!)
fi

if [ "${FLOPPY_START_DISCOVER_WORKER}" = "true" ]; then
    log "Starting celery discover worker"
    FLOPPY_PROCESS_ROLE=background \
        celery --app config worker --queues discover --hostname 'celery-discover@%h' \
        --loglevel "${loglevel}" --without-mingle --without-gossip &
    pids+=($!)
fi

log "Starting nginx on :8000"
nginx -e /dev/stderr -c /tmp/nginx/nginx.conf -g 'daemon off;' &
pids+=($!)

shutdown() {
    log "Stopping (signal received)"
    kill -TERM "${pids[@]}" 2>/dev/null || true
}
trap shutdown TERM INT

# Returns when the first child exits, or early when a trapped signal arrives.
status=0
wait -n || status=$?

trap - TERM INT
log "A process exited (status ${status}); stopping the rest"
kill -TERM "${pids[@]}" 2>/dev/null || true

# Celery's warm shutdown waits for running tasks, and imports may run for a long
# time. Bound the wait so a dead web tier restarts the container promptly.
grace="${FLOPPY_SHUTDOWN_GRACE:-25}"
for _ in $(seq "${grace}"); do
    alive=0
    for pid in "${pids[@]}"; do
        kill -0 "${pid}" 2>/dev/null && alive=1
    done
    [ "${alive}" -eq 0 ] && break
    sleep 1
done
kill -KILL "${pids[@]}" 2>/dev/null || true
wait || true
exit "${status}"
