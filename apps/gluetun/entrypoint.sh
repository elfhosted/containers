#!/bin/ash

# If we have snuck a VPN_ENDPOINT_IP value into /shared/VPN_ENDPOINT_IP, then use that instead of the current ENV VAR
if [[ -f /shared/VPN_ENDPOINT_IP ]]; then
    export VPN_ENDPOINT_IP=$(cat /shared/VPN_ENDPOINT_IP)
fi

# Allow us to write env files to /shared
if [[ -f /shared/env ]]; then
    source /shared/env
fi

# If we're in "sleep mode", then don't actually, just do nothing (useful when we control how a pod will run based on an env var)
if [[ ! -z "$ZURG_WARP_ENABLED" ]]; 
then
    echo "ZURG_WARP_ENABLED env var set, doing nothing (you are probably using WARP).."
    sleep infinity
else
    exec \
        /gluetun-entrypoint
fi