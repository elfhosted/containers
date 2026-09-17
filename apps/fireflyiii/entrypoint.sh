#!/bin/sh
set -eu

STORAGE="${LARAVEL_STORAGE_PATH:-/config}"
cd /app

# Laravel storage tree on the persistent volume
mkdir -p "${STORAGE}/app/public" "${STORAGE}/build" "${STORAGE}/database" \
    "${STORAGE}/debugbar" "${STORAGE}/export" "${STORAGE}/logs" "${STORAGE}/upload" \
    "${STORAGE}/framework/cache/data" "${STORAGE}/framework/sessions" \
    "${STORAGE}/framework/testing" "${STORAGE}/framework/views/twig" \
    "${STORAGE}/framework/views/v1" "${STORAGE}/framework/views/v2"

# Scratch dirs (/tmp is an emptyDir/tmpfs)
mkdir -p /tmp/laravel /tmp/nginx/client_body /tmp/nginx/proxy /tmp/nginx/fastcgi /tmp/nginx/uwsgi /tmp/nginx/scgi

# Allow secrets from mounted files: APP_KEY_FILE, STATIC_CRON_TOKEN_FILE, MAIL_PASSWORD_FILE
for var in APP_KEY STATIC_CRON_TOKEN MAIL_PASSWORD; do
    file_var="${var}_FILE"
    eval "file_path=\${${file_var}:-}"
    if [ -n "${file_path}" ]; then
        eval "current=\${${var}:-}"
        if [ -n "${current}" ]; then
            echo "Both ${var} and ${file_var} are set; they are exclusive" >&2
            exit 1
        fi
        export "${var}=$(cat "${file_path}")"
        unset "${file_var}"
    fi
done

# No APP_KEY supplied: generate one on first run and keep it on the volume, so
# sessions and encrypted settings survive restarts without a separate secret.
if [ -z "${APP_KEY:-}" ]; then
    if [ ! -s "${STORAGE}/app_key" ]; then
        echo "APP_KEY not set; generating ${STORAGE}/app_key"
        (umask 077 && head -c 24 /dev/urandom | base64 | tr -d '\n' > "${STORAGE}/app_key")
    fi
    APP_KEY="$(cat "${STORAGE}/app_key")"
    export APP_KEY
fi
if [ "${#APP_KEY}" -ne 32 ]; then
    echo "APP_KEY must be exactly 32 characters (got ${#APP_KEY})" >&2
    exit 1
fi

if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ] && [ -z "${DB_DATABASE:-}" ]; then
    touch "${STORAGE}/database/database.sqlite"
fi

# Same bootstrap sequence as upstream's docker entrypoint
php artisan config:clear >/dev/null
php artisan firefly-iii:create-database
php artisan firefly-iii:upgrade-database
php artisan firefly-iii:laravel-passport-keys
chmod 600 "${STORAGE}/oauth-public.key" "${STORAGE}/oauth-private.key" 2>/dev/null || true
php artisan firefly-iii:set-latest-version --james-is-cool
php artisan cache:clear >/dev/null 2>&1 || true
php artisan view:clear >/dev/null 2>&1 || true
php artisan config:cache >/dev/null
php artisan event:cache >/dev/null
php artisan firefly-iii:verify-security-alerts || true
rm -rf "${STORAGE}/framework/cache/data/"*

php-fpm -F &
PHP_FPM_PID=$!

nginx -e /dev/stderr -g 'daemon off;' &
NGINX_PID=$!

# Recurring transactions, auto-budgets, bill reminders: upstream asks for a daily
# `firefly-iii:cron`. The command tracks its own last-run dates, so running it
# hourly from here is safe and avoids a separate CronJob.
CRON_INTERVAL="${FIREFLY_CRON_INTERVAL:-3600}"
(
    while true; do
        sleep "${CRON_INTERVAL}"
        php /app/artisan firefly-iii:cron || echo "firefly-iii:cron failed" >&2
    done
) &
CRON_PID=$!

STOPPING=0
shutdown() {
    STOPPING=1
    kill -TERM "${CRON_PID}" 2>/dev/null || true
    kill -QUIT "${NGINX_PID}" 2>/dev/null || true
    kill -QUIT "${PHP_FPM_PID}" 2>/dev/null || true
}
trap shutdown TERM INT QUIT

# Exit (and let the pod restart) if either daemon dies. The sleep runs in the
# background so a stop signal interrupts the wait promptly.
while kill -0 "${PHP_FPM_PID}" 2>/dev/null && kill -0 "${NGINX_PID}" 2>/dev/null; do
    sleep 5 &
    wait $! || true
done

if [ "${STOPPING}" = "1" ]; then
    while kill -0 "${NGINX_PID}" 2>/dev/null || kill -0 "${PHP_FPM_PID}" 2>/dev/null; do
        sleep 1 &
        wait $! || true
    done
    exit 0
fi

echo "nginx or php-fpm exited unexpectedly" >&2
kill -TERM "${CRON_PID}" 2>/dev/null || true
kill -QUIT "${NGINX_PID}" "${PHP_FPM_PID}" 2>/dev/null || true
wait || true
exit 1
