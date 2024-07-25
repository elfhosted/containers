#!/bin/ash

cd /storage
/usr/bin/rclone serve webdav \
    --addr :5574 \
    --user ${WEBDAV_USERNAME} \
    --pass "${WEBDAV_PASSWORD}" \
    --max-header-bytes=8192 \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=10M \
    --stats 60s \
    --copy-links \
    -v \
    /storage
