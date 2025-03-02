#!/bin/bash

# We need to point /app/.env to /config/.env for persistence
touch /config/.env
ln -sf /config/.env /app/.env

# Fresh logs
log_file="/logs/$(date +'%Y-%m-%d').log"
rm /config/seerrbridge.log
ln -sf /config/seerrbridge.log $log_file

# Remove logs older than 7 days
find /logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

if [[ -z "$OVERSEERR_API_KEY" || -z "$TRAKT_API_KEY" ]]; 
then
    echo "SeerrBridge uses DebridMediaManager to fulfill Overseerr requests

Before SeerBridge will run, you need to define:
- OVERSEERR_API_KEY (even if it's provided by Jellyseerr)
- TRAKT_API_KEY
- RealDebrid/DMM credentials

See https://docs.elfhosted.com/app/seerrbridge for further details"
    sleep infinity 
fi

.local/bin/uvicorn seerrbridge:app --host 0.0.0.0 --port 8777

echo "SeerrBridge has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300