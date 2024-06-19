#!/bin/bash

# If gluetun vars exist, then don't actually, just do nothing (useful when we control how a pod will run based on an env var)
if [[ ! -z "$VPN_SERVICE_PROVIDER" ]]; 
then
    echo "VPN_SERVICE_PROVIDER env var set, doing nothing (you are probably using gluetun).."
    sleep infinity
else
    exec \
        /orig-entrypoint.sh
fi