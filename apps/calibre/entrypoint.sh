#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2086
XDG_RUNTIME_DIR=/tmp/runtime-root /usr/bin/calibre-server \
    --disable-use-bonjour \
    --enable-local-write \
    --trusted-ips="10.0.0.0/8" \
    "$@" \
    "/media/books"
