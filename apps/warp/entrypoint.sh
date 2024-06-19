#!/bin/bash

# If gluetun vars exist, then don't actually, just do nothing (useful when we control how a pod will run based on an env var)
if [[ ! -z "$ZURG_GLUETUN_ENABLED" ]]; 
then
    echo "ZURG_GLUETUN_ENABLED env var set, doing nothing (you are probably using gluetun).."
    sleep infinity
else
    exec \
        /orig-entrypoint.sh
fi