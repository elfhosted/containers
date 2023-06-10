#!/bin/bash
set -e
while true
do
    date
    echo "Checking that critical qBittorrent settings have not been tampered with..."
    grep -q 'Session\\MaxRatioAction=1' /config/qBittorrent/qBittorrent.conf
    grep -q 'Session\\GlobalMaxRatio=1' /config/qBittorrent/qBittorrent.conf
    echo "Sleeping 5 min..."
    sleep 5m
done