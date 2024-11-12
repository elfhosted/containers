#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

# Calibre will not start unless there is a database
if [ ! -f "/media/metadata.db" ]; then
    echo 'Creating an empty calibre metadata database at [/media/metadata.db]'
    touch /media/metadata.db
fi

#shellcheck disable=SC2086
XDG_RUNTIME_DIR=/tmp/runtime-root /usr/bin/calibre-server \
    --port="${CALIBRE_SERVER_PORT:-8080}" \
    --enable-local-write \
    --disable-use-bonjour \
    --trusted-ips="${CALIBRE_SERVER_TRUSTED_IPS:-'192.168.0.0/16,172.16.0.0/12,10.0.0.0/8'}" \
    "$@" \
    /media