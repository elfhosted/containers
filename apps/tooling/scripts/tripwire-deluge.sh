#!/bin/bash
set -e
while true
do
    date
    echo "Checking that critical Deluge settings have not been tampered with..."
    grep -q '"remove_seed_at_ratio": true,' /config/core.conf
    grep -q '"stop_seed_ratio": 1,' /config/core.conf
    echo "Sleeping 5 min..."
    sleep 5m
done