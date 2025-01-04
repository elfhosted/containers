#!/bin/bash

if [[ -z "$OVERSEERR_API_KEY" || -z "$TRAKT_API_KEY" ]]; 
then
    echo "SeerrBridge uses DebridMediaManager to fulfill Overseerr requests"
    echo "Before SeerBridge will run, you need to define your OVERSEERR_API_KEY, your TRAKT_API_KEY, and"
    echo "your RealDebrid/DMM credentials"
    echo "See https://docs.elfhosted.com/app/seerrbridge for further details"
    sleep infinity 
fi

.local/bin/uvicorn seerrbridge:app --host 0.0.0.0 --port 8777

echo "SeerrBridge has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300