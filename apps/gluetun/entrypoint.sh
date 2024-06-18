#!/bin/ash

# If we have snuck a VPN_ENDPOINT_IP value into /shared/VPN_ENDPOINT_IP, then use that instead of the current ENV VAR
if [[ -f /shared/VPN_ENDPOINT_IP ]]; then
    export VPN_ENDPOINT_IP=$(cat /shared/VPN_ENDPOINT_IP)
fi

# If we're in "sleep mode", then don't actually, just do nothing (useful when we control how a pod will run based on an env var)
if [[ ! -z "$SLEEP_MODE" ]]; 
then
    echo "SLEEP_MODE env var set, doing nothing (you are probably using WARP).."
    sleep infinity
else
    exec \
        /gluetun-entrypoint
fi