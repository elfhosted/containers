#!/bin/bash

# Define the function to be executed when the file changes
refresh_mounts() {
    for MOUNT in $(grep '^\[.*\]$' "/config/rclone.conf" | grep -v storage | sed 's/^\[\(.*\)\]$/\1/'); do
    rclone rc mount/mount fs=$MOUNT: mountPoint=/mount/$MOUNT
done
}

# run once the first time
refresh_mounts

# Loop indefinitely, monitoring for changes
while true; do
    # Wait for any changes to the file
    inotifywait -e modify "/config/rclone.conf"
    
    # Call the function when the file is modified
    refresh_mounts
done
