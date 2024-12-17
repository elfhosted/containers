#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

exec \
    /usr/bin/tinyproxy -d