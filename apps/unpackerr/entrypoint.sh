#!/usr/bin/env bash

#shellcheck disable=SC2086
if [ -f /config/unpackerr.conf ];
then
exec \
    /app/unpackerr \
        -c "/config/unpackerr.conf"
else
exec \
    /app/unpackerr
fi