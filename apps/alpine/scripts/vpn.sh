#!/usr/bin/env bash

if [[ "${WAIT_FOR_VPN:-"false"}" == "true" ]]; then
    echo "Waiting for VPN to be connected..."
    while ! grep -s -q "connected" /shared/vpnstatus; do
        # Also account for gluetun-style http controller - confirm that our public IP exists and doesn't belong to hetzner
        if (timeout 2s curl -s http://localhost:8000/v1/publicip/ip | grep public_ip | -vi hetzner); then
            break
        fi    
        echo "VPN not connected"
        sleep 2
    done
    echo "VPN Connected, starting application..."
fi
