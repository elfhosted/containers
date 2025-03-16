#!/bin/bash

if [[ -z "$OVERSEERR_API_KEY" ]]; 
then
    echo "SeerrBridge uses DebridMediaManager to fulfill Overseerr requests

Before SeerBridge will run, you need to define:
- OVERSEERR_API_KEY (even if it's provided by Jellyseerr)
- RealDebrid/DMM credentials

See https://docs.elfhosted.com/app/seerrbridge for further details"
    sleep infinity 
fi

# If we don't have a /config/.env, but we do have RD_ACCESS_TOKEN, then populate it
if [[ ! -f /config/.env && ! -z "$RD_ACCESS_TOKEN" ]]; then
  env | grep RD_ACCESS_TOKEN > /config/.env
fi

.local/bin/uvicorn seerrbridge:app --host 0.0.0.0 --port 8777

echo "SeerrBridge has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300