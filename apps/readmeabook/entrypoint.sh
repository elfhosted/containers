#!/bin/bash
set -e

READY_TIMEOUT=${APP_READY_TIMEOUT:-60}
INIT_RETRIES=${APP_INIT_RETRIES:-5}
REDIS_READY_TIMEOUT=${REDIS_READY_TIMEOUT:-60}
INIT_MAX_SECONDS=${APP_INIT_MAX_SECONDS:-600}
# The chart sets PORT explicitly, so hardcoding 3030 here would put init one
# config edit away from silently never running again.
APP_PORT=${PORT:-3030}
APP_URL="http://localhost:${APP_PORT}"

# Sync the Prisma schema before starting the app. The database runs as a
# postgres sidecar in the same pod, so on a cold start the app container can
# win the race and reach this point before postgres is accepting connections.
# Retry until the push succeeds; fail hard (crashloop) if it never does, rather
# than starting the app against an empty schema and hiding a broken instance.
echo "Running database migrations..."
attempts=0
max_attempts=30
until npx prisma db push --skip-generate --accept-data-loss; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge "${max_attempts}" ]; then
        echo "ERROR: prisma db push failed after ${max_attempts} attempts, exiting"
        exit 1
    fi
    echo "prisma db push failed (attempt ${attempts}/${max_attempts}); database may not be ready, retrying in 3s..."
    sleep 3
done
echo "Database schema is up to date."

# GET /api/init is the ONLY caller of schedulerService.start(), and nothing in
# the app initialises it lazily. Skip it and the scheduled_jobs table is never
# seeded, no Bull repeatables are registered, and credential migration never
# runs — the app looks healthy but library scans, retry-failed-imports, RSS
# monitoring and cleanup silently never fire. Upstream calls it from
# docker/unified/app-start.sh; we don't use that script, so we do it here.
#
# That means node can no longer be exec'd: it runs in the background so we can
# reach the init endpoint. Everything below exists to give back what exec gave
# for free — signal forwarding, prompt exit when node dies, honest timeouts.
node server.js &
SERVER_PID=$!

# A shutdown can land mid-startup (rollout superseded, failed scheduling, an
# admin deleting the pod). Bash finishes the running command before handling a
# trap, so every wait below must be interruptible and every loop must re-check
# this flag — otherwise we keep polling a node we already killed.
shutting_down=false
INIT_CURL_PID=""
forward_term() {
    shutting_down=true
    kill -TERM "${SERVER_PID}" 2>/dev/null || true
    # Without this the deferred trap waits out the in-flight init request, and
    # node never sees SIGTERM before the grace period expires and k8s SIGKILLs.
    if [ -n "${INIT_CURL_PID}" ]; then
        kill -TERM "${INIT_CURL_PID}" 2>/dev/null || true
    fi
}
trap forward_term TERM INT

server_alive() {
    kill -0 "${SERVER_PID}" 2>/dev/null
}

# If node exits at any point we must stop and let the container die, so the
# runtime restarts it as promptly as `exec node server.js` used to.
reap_server() {
    echo "ERROR: server process (PID ${SERVER_PID}) exited during startup"
    set +e
    wait "${SERVER_PID}"
    exit $?
}

# Wait for the app AND its database — /api/health checks both.
#
# Deadlines are measured in elapsed seconds, not iterations: each pass can burn
# curl's --max-time plus the sleep, so an iteration count would make a "60s"
# timeout run for minutes and delay the restart of a genuinely broken app.
ready=false
started_at=${SECONDS}
deadline=$(( SECONDS + READY_TIMEOUT ))
while [ "${SECONDS}" -lt "${deadline}" ]; do
    if [ "${shutting_down}" = "true" ]; then
        break
    fi
    if ! server_alive; then
        reap_server
    fi
    # --max-time matters for more than politeness: bash defers the SIGTERM trap
    # until the running command returns, so an unbounded curl against a wedged
    # app would stall pod termination behind it.
    if curl -sf --max-time 5 -o /dev/null "${APP_URL}/api/health"; then
        ready=true
        echo "Server is healthy (took $(( SECONDS - started_at ))s)"
        break
    fi
    sleep 1
done

if [ "${shutting_down}" = "true" ]; then
    echo "Shutdown requested during startup; skipping init"
elif [ "${ready}" = "false" ]; then
    echo "WARNING: server did not become healthy within ${READY_TIMEOUT}s; skipping init"
    echo "WARNING: scheduled jobs will be missing until the next restart"
else
    # Redis answers -LOADING while it replays its AOF/RDB, and /api/health only
    # checks postgres. Initialising before redis is up floods the log with
    # LOADING errors from the Bull queues. redis-cli isn't in this image, so
    # PING over bash's /dev/tcp.
    #
    # Read the target out of REDIS_URL rather than hardcoding the sidecar: a
    # tenant pointed at an external redis would otherwise sit through this whole
    # timeout probing a localhost that nobody is listening on.
    redis_host="127.0.0.1"
    redis_port="6379"
    redis_probe=true
    case "${REDIS_URL:-}" in
        # A raw PING can't speak TLS, so don't pretend to probe it.
        rediss://*)
            redis_probe=false
            ;;
        *://*)
            redis_authority=${REDIS_URL#*://}   # strip scheme
            redis_authority=${redis_authority%%/*}   # strip /0 database suffix
            redis_authority=${redis_authority##*@}   # strip user:password@
            case "${redis_authority}" in
                # Bracketed IPv6, e.g. [2001:db8::1]:6379 — splitting on the
                # first colon would yield the host "[2001" and stall the probe
                # for the whole timeout on an endpoint the app connects to fine.
                \[*\]*)
                    redis_host=${redis_authority%%]*}
                    redis_host=${redis_host#\[}
                    redis_port_part=${redis_authority##*]}
                    case "${redis_port_part}" in
                        :*) redis_port=${redis_port_part#:} ;;
                    esac
                    ;;
                ?*)
                    redis_host=${redis_authority%%:*}
                    if [ "${redis_authority}" != "${redis_host}" ]; then
                        redis_port=${redis_authority##*:}
                    fi
                    ;;
            esac
            [ -n "${redis_host}" ] || redis_host="127.0.0.1"
            [ -n "${redis_port}" ] || redis_port="6379"
            ;;
    esac

    if [ "${redis_probe}" = "false" ]; then
        echo "Skipping redis readiness probe (TLS endpoint)"
    else
        redis_deadline=$(( SECONDS + REDIS_READY_TIMEOUT ))
        redis_ready=false
        while [ "${SECONDS}" -lt "${redis_deadline}" ]; do
            if [ "${shutting_down}" = "true" ]; then
                break
            fi
            if ! server_alive; then
                reap_server
            fi
            # Run the probe in a `timeout`-wrapped subshell rather than opening
            # /dev/tcp here: a stalled DNS lookup or a host silently dropping
            # SYNs blocks that redirection for the kernel's connect timeout —
            # minutes — and the loop's deadline is only checked between
            # iterations, so it would sail straight past REDIS_READY_TIMEOUT.
            # Its stderr is discarded because bash reports a failed /dev/tcp
            # connect itself, which is the per-poll noise this loop exists to avoid.
            reply=$(timeout 3 bash -c '
                exec 3<>"/dev/tcp/$0/$1" || exit 1
                printf "PING\r\n" >&3 || exit 1
                read -r -t 2 line <&3 || exit 1
                printf "%s" "${line}"
            ' "${redis_host}" "${redis_port}" 2>/dev/null) || reply=""
            case "${reply}" in
                # -NOAUTH proves the server is up and past loading just as well
                # as +PONG does; only -LOADING or no answer means keep waiting.
                +PONG*|-NOAUTH*)
                    redis_ready=true
                    echo "Redis is ready"
                    break
                    ;;
            esac
            sleep 1
        done
        if [ "${redis_ready}" = "false" ] && [ "${shutting_down}" = "false" ]; then
            echo "WARNING: redis not ready after ${REDIS_READY_TIMEOUT}s, initialising anyway"
        fi
    fi

    # Seeds the default scheduled jobs, registers the Bull repeatables and runs
    # credential migration. Idempotent, so it's safe on every boot.
    echo "Initializing application services..."
    init_ok=false
    init_timed_out=false
    for attempt in $(seq 1 "${INIT_RETRIES}"); do
        if [ "${shutting_down}" = "true" ]; then
            echo "Shutdown requested; abandoning init"
            break
        fi
        if ! server_alive; then
            reap_server
        fi
        # Backgrounded so the wait is interruptible: a stalled init must not
        # outlast the pod's termination grace period. That trap — not the
        # timeout — is what keeps shutdown prompt, so --max-time can afford to
        # be generous, and needs to be: /api/init also triggers overdue jobs
        # inline, so on a tenant with a backlog it legitimately runs for
        # minutes (observed: >60s while it worked through stuck imports).
        curl -sf --max-time "${INIT_MAX_SECONDS}" -o /dev/null "${APP_URL}/api/init" &
        INIT_CURL_PID=$!
        set +e
        wait "${INIT_CURL_PID}"
        curl_rc=$?
        set -e
        INIT_CURL_PID=""
        if [ "${curl_rc}" -eq 0 ]; then
            init_ok=true
            echo "Application services initialized"
            break
        fi
        # Don't report a failure or sleep off a backoff we're about to abandon —
        # the loop head reports the shutdown and breaks.
        if [ "${shutting_down}" = "true" ]; then
            continue
        fi
        # A timeout means the request is still being served, not that it failed.
        # Retrying would start a second scheduler run concurrently with the
        # first and double-register the Bull repeatables, so stop here and let
        # the in-flight one finish.
        if [ "${curl_rc}" -eq 28 ]; then
            init_timed_out=true
            echo "WARNING: init still running server-side after ${INIT_MAX_SECONDS}s; not retrying"
            break
        fi
        # curl's own codes are the diagnostic here: 7 refused, 22 HTTP error,
        # 28 timed out, >128 killed by our trap.
        echo "Init attempt ${attempt}/${INIT_RETRIES} failed (curl exit ${curl_rc}), retrying in ${attempt}s..."
        sleep "${attempt}"
    done

    # Non-fatal by design: a scheduler hiccup shouldn't crashloop the whole app
    # and take the UI down with it. Loud enough to spot in the logs.
    if [ "${init_ok}" = "false" ] && [ "${shutting_down}" = "false" ] && [ "${init_timed_out}" = "false" ]; then
        echo "ERROR: failed to initialize application services after ${INIT_RETRIES} attempts"
        echo "ERROR: scheduled jobs will be missing — check the log above for details"
    fi
fi

# Propagate node's exit code. The first wait returns early when the trap fires,
# so wait again for the real exit status once SIGTERM has been forwarded.
set +e
wait "${SERVER_PID}"
rc=$?
if [ "${rc}" -gt 128 ]; then
    wait "${SERVER_PID}"
    rc=$?
fi
exit "${rc}"
