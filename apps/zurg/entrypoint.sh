#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

if [[ "${WAIT_FOR_WARP:-"false"}" == "true" ]]; then
    echo "Waiting for WARP to be connected..."
    # Also account for gluetun-style http controller
    if (timeout 2s curl --silent --socks5 127.0.0.1:1080 https://www.cloudflare.com | grep -q cloudflare ); then
        break
    fi    
    echo "WARP not connected"
    sleep 2
    echo "WARP Connected, starting application..."
fi

cd /config
#shellcheck disable=SC2086
exec \
    /app/zurg --config /config/config.yml