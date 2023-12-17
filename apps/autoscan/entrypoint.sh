#!/usr/bin/env bash

# If there's no config.yml presented, then add a basic one so that goss can pass tests
if [[ ! -f "/config/config.yml" ]]; then
    echo "port: 3030" > /config/config.yml
fi

exec \
    /app/autoscan/autoscan
