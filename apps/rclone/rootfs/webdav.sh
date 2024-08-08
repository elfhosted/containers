#!/bin/ash

cd /storage

if [[ ! -z "${WEBDAV_PASSWORD}" ]]; then
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
else
    mkdir /tmp/no-password
    echo "WebDAV password not set. See https://elfhosted.com/app/webdav/ for instructions" > /tmp/no-password/README.txt
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
    /tmp/no-password    
fi