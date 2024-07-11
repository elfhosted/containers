#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

if [[ "${WAIT_FOR_WARP:-"false"}" == "true" ]]; then
    echo "Waiting for WARP to be connected..."
    while true; do
        # Wait to confirm WARP is ready
        if (curl --silent --socks5 127.0.0.1:1080 https://www.cloudflare.com | grep -q cloudflare ); then
            echo "WARP Connected, starting application..."
            break
        fi    
        echo "WARP not connected"
        sleep 2
    done
fi

cd /config
#shellcheck disable=SC2086
exec \
    /app/zurg --config /config/config.yml