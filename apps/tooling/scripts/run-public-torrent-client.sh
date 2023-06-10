#!/bin/bash
while true
do
    date
    echo "Retreving public_torrent_client.sh from B2..."
    s3cmd --config /.s3cfg sync -v s3://goldilocks/config/public_torrent_client.sh /tmp/
    echo "Running /tmp/public_torrent_client.sh..."
    bash /tmp/public_torrent_client.sh
    echo "Sleeping 5 min..."
    sleep 5m
done