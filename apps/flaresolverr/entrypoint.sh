#!/usr/bin/env bash

/usr/bin/dumb-init /bin/bash -c
|

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

cd /config
#shellcheck disable=SC2086
exec \
    /usr/local/bin/python -u /app/flaresolverr.py