#!/bin/bash

SRC=$1
DST=$2
INTERVAL=$3

function backupconfig_on_shutdown {
    set +x
    echo "Received SIGTERM, waiting 10s for app to shut down..."
    sleep 5s
    sync
    time rsync -avr --delete-after /$SRC/* /$DST/
    sync
}

function backupconfig {
    set +x
    echo "Copying contents of /tmp to /config..."
    sync
    time rsync -avr --delete-after /$SRC/* /$DST/
    sync
}

# When we terminate, do one more backup
trap backupconfig_on_shutdown SIGTERM

# While running normally, backup every 30 min
while true
do
    backupconfig
    echo "Sleeping $INTERVAL..."
    sleep $INTERVAL
done
