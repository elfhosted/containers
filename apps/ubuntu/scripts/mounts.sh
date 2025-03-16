#!/bin/bash

# If the environment variable is not set or empty, proceed immediately
if [ -z "$WAIT_FOR_MOUNT_PATHS" ]; then
    echo "WAIT_FOR_MOUNT_PATHS is empty or not set. Proceeding immediately..."
    
else

    echo "Waiting for the following mount paths to become available:"
    # Use a standard IFS approach for ash compatibility
    OLD_IFS="$IFS"
    IFS=","
    for dir in $WAIT_FOR_MOUNT_PATHS; do
        echo "- $dir"
    done
    IFS="$OLD_IFS"

    # Function to check if all directories exist
    check_dirs() {
        all_exist=true
        OLD_IFS="$IFS"
        IFS=","
        for dir in $WAIT_FOR_MOUNT_PATHS; do
            if [ ! -d "$dir" ]; then
                all_exist=false
                break
            fi
        done
        IFS="$OLD_IFS"
        echo "$all_exist"
    }

    # Wait until all directories exist
    while [ "$(check_dirs)" = "false" ]; do
        echo "$(date): Waiting for all directories to become available..."
        
        # Print status of each directory
        OLD_IFS="$IFS"
        IFS=","
        for dir in $WAIT_FOR_MOUNT_PATHS; do
            if [ -d "$dir" ]; then
                echo "- Available: $dir"
            else
                echo "- Waiting for: $dir"
            fi
        done
        IFS="$OLD_IFS"
        
        # Wait for 5 seconds before checking again
        sleep 5
    done

    echo "$(date): All directories are now available!"

    # Your actual script logic goes here
    echo "Proceeding with operations..."
fi

# Example: listing files in all directories
# OLD_IFS="$IFS"
# IFS=","
# for dir in $WAIT_FOR_MOUNT_PATHS; do
#     echo "Contents of $dir:"
#     ls -la "$dir"
#     echo ""
# done
# IFS="$OLD_IFS"