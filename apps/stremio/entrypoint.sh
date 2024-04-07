#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

#shellcheck disable=SC2086
cd /srv/stremio-server
exec \
    ./stremio-web-service-run.sh