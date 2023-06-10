#!/usr/bin/env bash

set -e

qbtLogFile=/config/qBittorrent/qBittorrent/logs/qbittorrent.log
if [ -f "$qbtLogFile" ] 
then
    rm $qbtLogFile
fi
mkdir -p /config/qBittorrent/qBittorrent/logs/
ln -sf /proc/self/fd/1 "$qbtLogFile"

exec /usr/local/bin/qbittorrent-nox