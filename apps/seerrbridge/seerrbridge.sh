#!/bin/bash

# We need to point /app/.env to /config/.env for persistence
touch /config/.env
ln -sf /config/.env /app/.env

if [[ -z "$OVERSEERR_API_KEY" || -z "$TRAKT_API_KEY" ]]; 
then
    echo "SeerrBridge uses DebridMediaManager to fulfill Overseerr requests

Before SeerBridge will run, you need to define:
- OVERSEERR_API_KEY
- TRAKT_API_KEY
- RealDebrid/DMM credentials

See https://docs.elfhosted.com/app/seerrbridge for further details"
    sleep infinity 
fi

# Create log directory if it doesn't exist
mkdir -p /logs

# Log file path (using date for daily log)
log_file="/logs/$(date +'%Y-%m-%d').log"

# Remove logs older than 7 days
find /logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

.local/bin/uvicorn seerrbridge:app --host 0.0.0.0 --port 8777 2>&1 | tee -a "$log_file"

echo "SeerrBridge has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300