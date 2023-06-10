#!/bin/bash

function backupqueue {
    set +x
    echo "Received SIGTERM, waiting 2s for app to shut down..."
    sleep 2s

    TMP_SIZE=$(du -bs /tmp | cut -f1)
    TMP_LIMIT=96636764160 #90GB
    if [ "$TMP_SIZE" -le "$TMP_LIMIT" ]; then
        if [ ! -z "$(ls -A /tmp/)" ]; then
            echo "Copying /tmp/* to /queue/..."
            time cp -rfv /tmp/* /queue/
            echo "Transfer complete"
        fi
    fi
}

trap backupqueue SIGTERM

echo "Waiting for SIGTERM to start offloading /tmp to /queue..."
sleep infinity