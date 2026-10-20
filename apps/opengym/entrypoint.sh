#!/bin/sh
# Runs the openGym API and its nginx front in one container.
set -u

DATA_DIR="${DATA_DIR:-/config}"
POLL_SECONDS="${OPENGYM_POLL_SECONDS:-3}"

truthy() {
    case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
        1|true|yes|on) return 0 ;;
    esac
    return 1
}

no_profiles() {
    node -e '
        const fs = require("fs");
        let raw;
        try { raw = fs.readFileSync(process.argv[1], "utf8"); }
        catch (e) { process.exit(e.code === "ENOENT" ? 0 : 1); }
        try { const d = JSON.parse(raw); process.exit(Array.isArray(d.users) && d.users.length === 0 ? 0 : 1); }
        catch { process.exit(1); }
    ' "${DATA_DIR}/db.json"
}

alive() {
    [ -r "/proc/$1/status" ] && ! grep -q '^State:[[:space:]]*Z' "/proc/$1/status" 2>/dev/null
}

bootstrap=0
if truthy "${INVITE_ONLY:-}" && truthy "${OPENGYM_OPEN_UNTIL_FIRST_PROFILE:-}" && no_profiles; then
    bootstrap=1
fi

api_pid=""
next_pid=""
hold_pid=""
nginx_pid=""
OPEN_PORT=3000      # open-sign-up API, only while there is no profile yet
FINAL_PORT=3001     # the API as configured
HOLD_PORT=3002      # hold.js, only during the hand-over

start_api() {
    cd /app || exit 1
    if [ "$bootstrap" = 1 ]; then
        echo "opengym: no profiles yet; sign-up is open until the first profile is created, then invite-only"
        INVITE_ONLY=0 PORT="$OPEN_PORT" node server.js &
    else
        PORT="$FINAL_PORT" node server.js &
    fi
    api_pid=$!
}

shutdown() {
    trap - TERM INT
    [ -n "$nginx_pid" ] && kill -QUIT "$nginx_pid" 2>/dev/null
    [ -n "$api_pid" ] && kill -TERM "$api_pid" 2>/dev/null
    [ -n "$next_pid" ] && kill -TERM "$next_pid" 2>/dev/null
    [ -n "$hold_pid" ] && kill -TERM "$hold_pid" 2>/dev/null
    wait
    exit "${1:-0}"
}
trap 'shutdown 0' TERM INT

legacy_media=/config/exercise-media  # copy downloaded by earlier builds of this image
if [ -f "$legacy_media/.opengym-version" ]; then
    rm -rf "$legacy_media" \
        && echo "opengym: removed the old downloaded media copy from the data volume" \
        || echo "opengym: could not remove $legacy_media; continuing" >&2
fi

start_api
nginx -e /dev/stderr -g 'daemon off;' &
nginx_pid=$!

while :; do
    if [ "$bootstrap" = 1 ]; then sleep 1 & else sleep "$POLL_SECONDS" & fi
    wait $!

    if ! alive "$nginx_pid"; then
        echo "opengym: nginx exited; stopping" >&2
        shutdown 1
    fi
    if [ -n "$hold_pid" ] && ! alive "$hold_pid"; then
        wait "$hold_pid"
        hold_pid=""
    fi
    if ! alive "$api_pid"; then
        echo "opengym: api exited; stopping" >&2
        shutdown 1
    fi
    if [ "$bootstrap" = 1 ] && ! no_profiles; then
        echo "opengym: first profile created; handing over to the invite-only api"
        ready_file=/tmp/opengym-hold.ready
        rm -f "$ready_file"
        node /usr/local/lib/opengym-hold.js "$HOLD_PORT" "$FINAL_PORT" "$ready_file" &
        hold_pid=$!
        tries=0
        while [ ! -f "$ready_file" ] && [ "$tries" -lt 50 ] && alive "$hold_pid"; do
            sleep 0.1
            tries=$((tries + 1))
        done
        [ -f "$ready_file" ] || echo "opengym: hold proxy did not start; requests may fail during the swap" >&2
        kill -TERM "$api_pid" 2>/dev/null
        wait "$api_pid"
        api_pid=""
        cd /app || exit 1
        PORT="$FINAL_PORT" node server.js &
        next_pid=$!
        ready=0
        tries=0
        while [ "$tries" -lt 60 ] && alive "$next_pid"; do
            if wget -q -T 2 -O /dev/null "http://127.0.0.1:${FINAL_PORT}/api/health"; then
                ready=1
                break
            fi
            sleep 0.5
            tries=$((tries + 1))
        done
        if [ "$ready" != 1 ]; then
            echo "opengym: invite-only api did not come up; stopping" >&2
            shutdown 1
        fi
        api_pid=$next_pid
        next_pid=""
        bootstrap=0
        kill -TERM "$hold_pid" 2>/dev/null
        echo "opengym: sign-up is now invite-only"
    fi
done
