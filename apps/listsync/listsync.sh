#!/bin/bash

if [[ -z "$OVERSEERR_API_KEY" ]]; 
then
    echo "ListSync uses populates Overseerr / Jellyseerr with requests from IMDB, Trakt, or Letterboxd lists

Before ListSync will run, you need to define:
- OVERSEERR_API_KEY

See https://docs.elfhosted.com/app/listsync for further details"
    sleep infinity 
fi

python add.py

echo "ListSync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300