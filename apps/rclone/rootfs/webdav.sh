#!/bin/bash

cd /storage
/usr/bin/rclone serve webdav \
    --addr :5574 \
    --user ${WEBDAV_USERNAME} \
    --pass ${WEBDAV_PASSWORD} \
    --max-header-bytes=8192 \
    --no-modtime \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=10M \    
    --stats 60s \
    /storage

