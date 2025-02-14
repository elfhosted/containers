#!/bin/bash

# Define the function to be executed when the file changes
refresh_mounts() {
    for MOUNT in $(grep '^\[.*\]$' "/config/rclone.conf" | grep -v '\[storage\]' | sed 's/^\[\(.*\)\]$/\1/'); do
    mkdir -p /mount/remote/$MOUNT
    rclone rc mount/mount fs=$MOUNT: mountPoint=/mount/remote/$MOUNT vfsOpt='{"CacheMode": 3}'
done
}

# run once the first time
sleep 10s # wait for rclone to be running

if [ -f /config/rclone.conf ]; then
    refresh_mounts

    # Loop indefinitely, monitoring for changes
    while true; do
        # Wait for changes, handle errors gracefully
        inotifywait -e modify "/config/rclone.conf" || sleep 10
        
        # Ensure the file still exists before calling the function
        [ -f /config/rclone.conf ] && refresh_mounts
    done
fi

