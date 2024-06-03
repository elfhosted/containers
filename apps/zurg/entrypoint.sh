#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

cd /config
#shellcheck disable=SC2086
exec \
    /app/zurg --config /config/config.yml