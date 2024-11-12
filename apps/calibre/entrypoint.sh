#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2086
export XDG_RUNTIME_DIR=/tmp/runtime-root 
export CALIBRE_SERVER_BOOKS_PATH="${CALIBRE_SERVER_BOOKS_PATH:="/media/books"}"
# Calibre will not start unless there is a database
if [ ! -f "${CALIBRE_SERVER_BOOKS_PATH}/metadata.db" ]; then
    echo "Creating an empty calibre metadata database at [${CALIBRE_SERVER_BOOKS_PATH}/metadata.db]"
    touch "${CALIBRE_SERVER_BOOKS_PATH}/metadata.db"
fi

/usr/bin/calibre-server \
    --port="${CALIBRE_SERVER_PORT:-8080}" \
    --enable-local-write \
    --disable-use-bonjour \
    --trusted-ips="${CALIBRE_SERVER_TRUSTED_IPS:-'192.168.0.0/16,172.16.0.0/12,10.0.0.0/8'}" \
    "$@" \
    "${CALIBRE_SERVER_BOOKS_PATH}"