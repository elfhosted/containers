#!/bin/bash

if [[ -z "${REALDEBRID_API_KEY}" && ${REALDEBRID_ENABLED+x} ]]; then
  echo "RealDebrid enabled (default) but REALDEBRID_API_KEY env var is not set"
  echo "Use ElfTerm to run 'elfbot env blackhole REALDEBRID_API_KEY=<your key>'"
  echo -e "\n\nNOTE: Blackhole is not REQUIRED. It's an optional alternative to RDTClient. You could just ignore this"
  sleep infinity
elif [[ -z "${TORBOX_API_KEY}" && ${TORBOX_ENABLED+x} ]]; then
  echo "Torbox enabled (manually) but TORBOX_API_KEY env var is not set"
  echo "Use ElfTerm to run 'elfbot env blackhole TORBOX_API_KEY=<your key>'"
  echo -e "\n\nNOTE: Blackhole is not REQUIRED. It's an optional alternative to RDTClient. You could just ignore this"
  sleep infinity
fi

# Create log directory if it doesn't exist
mkdir -p /config/logs

# Log file path (using date for daily log)
log_file="/config/logs/$(date +'%Y-%m-%d').log"

# Remove logs older than 7 days
find /config/logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

# Run the script, log output to both stdout and logfile
cd /app
python -u blackhole_watcher.py 2>&1 | tee -a "$log_file"

echo "Blackhole has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300
