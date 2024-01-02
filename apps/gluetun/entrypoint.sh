#!/bin/ash

# If we have snuck a VPN_ENDPOINT_IP value into /shared/VPN_ENDPOINT_IP, then use that instead of the current ENV VAR
if [[ -f /shared/VPN_ENDPOINT_IP ]]; then
    export VPN_ENDPOINT_IP=$(cat /shared/VPN_ENDPOINT_IP)
fi

exec \
    /gluetun-entrypoint
