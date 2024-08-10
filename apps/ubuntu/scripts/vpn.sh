#!/usr/bin/env bash

if [[ "${WAIT_FOR_VPN:-"false"}" == "true" ]]; then
    echo "Waiting for VPN to be connected..."
    while ! grep -s -q "connected" /shared/vpnstatus; do
        # Also account for gluetun-style http controller - undocumented feature from https://github.com/qdm12/gluetun/issues/2277#issuecomment-2115964521
        if (timeout 2s curl -s http://localhost:8000/v1/vpn/status | grep -q running); then
            break
        fi
        echo "VPN not connected"
        sleep 2
    done
    echo "VPN Connected, starting application..."
fi
