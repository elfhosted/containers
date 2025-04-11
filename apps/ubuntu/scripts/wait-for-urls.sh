#!/bin/bash

# If the environment variable is not set or empty, proceed immediately
if [ -z "$WAIT_FOR_URLS" ]; then
    echo "WAIT_FOR_URLS is empty or not set. Proceeding immediately..."
else
    echo "Waiting for the following URLs to return HTTP 200:"
    # Use a standard IFS approach for ash compatibility
    OLD_IFS="$IFS"
    IFS=","
    for url in $WAIT_FOR_URLS; do
        echo "- $url"
    done
    IFS="$OLD_IFS"

    # Function to check if all URLs return HTTP 200
    check_urls() {
        all_ok=true
        OLD_IFS="$IFS"
        IFS=","
        for url in $WAIT_FOR_URLS; do
            if ! curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
                all_ok=false
                break
            fi
        done
        IFS="$OLD_IFS"
        echo "$all_ok"
    }

    # Wait until all URLs return HTTP 200
    while [ "$(check_urls)" = "false" ]; do
        echo "$(date): Waiting for all URLs to return HTTP 200..."
                
        # Print status of each URL
        OLD_IFS="$IFS"
        IFS=","
        for url in $WAIT_FOR_URLS; do
            if curl -s --max-time 10 -o /dev/null "$url"; then
                echo "- Available: $url"
            else
                echo "- Waiting for: $url"
            fi
        done
        IFS="$OLD_IFS"
        
        # Wait for 5 seconds before checking again
        sleep 5
    done

    echo "$(date): All URLs are now returning HTTP 200!"

    # Your actual script logic goes here
    echo "Proceeding with operations in 10s... "
    sleep 10
fi