#!/bin/bash
# Replaces upstream's root entrypoint + supervisord. Runs entirely as the image
# user (568) with a read-only root filesystem: persistent state in /config,
# scratch in /tmp. tini (PID 1) runs this script, which starts the four
# long-running processes and exits as soon as any one of them does, so the
# orchestrator restarts the container instead of it limping on half-alive.
set -euo pipefail

log() {
    echo "[elf-entrypoint] $*"
}

cd /yamtrack

# SECRET signs sessions and CSRF tokens. Upstream falls back to a constant baked
# into settings.py, identical for every install. If neither SECRET nor
# SECRET_FILE is supplied, generate a random per-instance key once and keep it
# in /config so sessions survive restarts.
if [ -z "${SECRET:-}" ] && [ -z "${SECRET_FILE:-}" ]; then
    secret_path=/config/.yamtrack-secret
    if [ ! -s "${secret_path}" ]; then
        log "SECRET not set; generating a per-instance key at ${secret_path}"
        (umask 077 && python -c 'import secrets; print(secrets.token_urlsafe(50))' > "${secret_path}.tmp")
        mv "${secret_path}.tmp" "${secret_path}"
    fi
    SECRET="$(cat "${secret_path}")"
    export SECRET
fi

mkdir -p /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi \
         /tmp/nginx/uwsgi /tmp/nginx/scgi

if [ "${YAMTRACK_IPV6_ENABLED:-False}" = "True" ]; then
    sed 's/listen 8000;/listen 8000; listen [::]:8000;/' /etc/nginx/yamtrack.conf > /tmp/nginx/nginx.conf
else
    cp /etc/nginx/yamtrack.conf /tmp/nginx/nginx.conf
fi

case "${DEBUG:-False}" in
    [Tt]rue|1|[Yy]es|[Oo]n) loglevel=DEBUG ;;
    *) loglevel=INFO ;;
esac

log "Running database migrations"
python manage.py migrate --noinput

pids=()

log "Starting gunicorn on 127.0.0.1:8001"
gunicorn --control-socket /tmp/gunicorn.ctl --config python:config.gunicorn config.wsgi:application &
pids+=($!)

log "Starting celery worker"
celery --app config worker --loglevel "${loglevel}" --without-mingle --without-gossip &
pids+=($!)

log "Starting celery beat"
celery --app config beat --loglevel "${loglevel}" --schedule /tmp/celerybeat-schedule &
pids+=($!)

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

# Celery's warm shutdown waits for running tasks, and imports may run for hours.
# Bound the wait so a dead web tier restarts the container promptly.
grace="${YAMTRACK_SHUTDOWN_GRACE:-25}"
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
