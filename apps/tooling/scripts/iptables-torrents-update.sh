#!/bin/bash
while true
do
    date
    echo "Retreving iptables config from B2..."
    s3cmd --config /.s3cfg sync -v s3://goldilocks/config/iptables-torrents /tmp/
    echo "Restoring iptables..."
    iptables-restore /tmp/iptables-torrents
    echo "Sleeping 5 min..."
    sleep 5m
done