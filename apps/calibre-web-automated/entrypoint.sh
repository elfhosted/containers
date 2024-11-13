#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

# copy app to tmp location to avoid readonlyrootfs
cp /app/calibre-web /tmp -rfp

#shellcheck disable=SC2086
exec \
    /usr/bin/python3 \
        /tmp/calibre-web/cps.py \
            -p /config/app.db \
            -g /config/gd.db