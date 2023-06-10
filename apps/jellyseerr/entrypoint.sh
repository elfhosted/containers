#!/usr/bin/env bash

#shellcheck disable=SC2086
cd /app/overseerr || exit

export CONFIG_DIRECTORY="/config"

exec \
    /usr/bin/yarn start