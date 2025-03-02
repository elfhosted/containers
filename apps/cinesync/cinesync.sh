#!/bin/bash

# Log file path (using date for daily log)
log_file="/logs/$(date +'%Y-%m-%d').log"

# Remove logs older than 7 days
find /logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

python3 MediaHub/main.py --auto-select 2>&1 | tee -a "$log_file"

echo "Cinesync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300