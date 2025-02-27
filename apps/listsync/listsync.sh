#!/bin/bash

# if [[ -z "$OVERSEERR_API_KEY" || -z "$TRAKT_API_KEY" ]]; 
# then
#     echo "SeerrBridge uses DebridMediaManager to fulfill Overseerr requests

# Before SeerBridge will run, you need to define:
# - OVERSEERR_API_KEY
# - TRAKT_API_KEY
# - RealDebrid/DMM credentials

# See https://docs.elfhosted.com/app/seerrbridge for further details"
#     sleep infinity 
# fi

python add.py

echo "ListSync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300