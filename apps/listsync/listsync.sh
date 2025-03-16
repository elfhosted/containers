#!/bin/bash

if [[ -z "$OVERSEERR_API_KEY" ]]; 
then
    echo "ListSync uses populates Overseerr / Jellyseerr with requests from IMDB, Trakt, or Letterboxd lists

Before ListSync will run, you need to define at least:
- OVERSEERR_API_KEY

See https://docs.elfhosted.com/app/listsync for further details"
    sleep infinity 
fi

# Log file path (using date for daily log)
log_file="/logs/$(date +'%Y-%m-%d').log"

# Remove logs older than 7 days
find /logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

echo "👋 ListSync usually runs in automated (hands-off) mode. 
Press any key to drop to a shell for manual mode, or wait 10 seconds for a normal start... ⏱️"

# -t 10: Timeout of 10 seconds
read -s -n 1 -t 10

if [ $? -eq 0 ]; then
    echo "You pressed a key! Going to manual mode, a few things to note:

1️⃣ Hit enter whenever prompted for a password, it's unnecessary
2️⃣ If prompted for it, your Overseerr URL is $OVERSEERR_URL, and you'll have to retrieve the API key from your instance yourself"

    AUTOMATED_MODE=false python add.py
else
    echo "Timeout reached, running ListSync in automated mode.."
    AUTOMATED_MODE=true python add.py 2>&1 | tee -a "$log_file"
fi

echo "ListSync has exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300