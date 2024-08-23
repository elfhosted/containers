#!/bin/bash

# get our env vars from persistent storage
export $(cat /config/blackhole.env | grep -vE "^#" | xargs)

# run the script
cd /app
python blackhole_watcher.py