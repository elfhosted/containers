#!/bin/bash

# get our env vars from persistent storage
export $(cat /config/blackhole.env | grep -vE "^#" | xargs)

# run the script
cd /app
python blackhole_watcher.py
echo "Blackhole has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300