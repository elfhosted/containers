#!/bin/bash

if [[ -z "${REALDEBRID_API_KEY}" && ${REALDEBRID_ENABLED+x} ]]; then
  echo "REALDEBRID_API_KEY env var is not set"
  echo "Use ElfTerm to run 'elfbot env blackhole REALDEBRID_API_KEY=<your key>'"
  echo -e "\n\nNOTE: Blackhole is not REQUIRED. It's an optional alternative to RDTClient. You could just ignore this"
  sleep infinity
elif [[ -z "${TORBOX_API_KEY}" && ${TORBOX_ENABLED+x} ]]; then
  echo "TORBOX_API_KEY env var is not set"
  echo "Use ElfTerm to run 'elfbot env blackholetorbox TORBOX_API_KEY=<your key>'"
  echo -e "\n\nNOTE: Blackhole is not REQUIRED. It's an optional alternative to RDTClient. You could just ignore this"
  sleep infinity
fi

# Create log directory if it doesn't exist
mkdir -p /config/logs

# Log file path (using date for daily log)
log_file="/config/logs/$(date +'%Y-%m-%d').log"

# Remove logs older than 7 days
find /config/logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

# move unprocessed files back into watch dir for processing
move_files_if_exists() {
  local src_dir=$1
  local dest_dir=$2

  if [ ! -z "$(ls -A ${src_dir})" ]; then
    mv ${src_dir}/* ${dest_dir}
  fi
}

# move_files_if_exists "${BLACKHOLE_BASE_WATCH_PATH}/${BLACKHOLE_RADARR_PATH}/processing" "${BLACKHOLE_BASE_WATCH_PATH}/${BLACKHOLE_RADARR_PATH}"
# move_files_if_exists "${BLACKHOLE_BASE_WATCH_PATH}/${BLACKHOLE_SONARR_PATH}/processing" "${BLACKHOLE_BASE_WATCH_PATH}/${BLACKHOLE_SONARR_PATH}"

# Run the script, log output to both stdout and logfile
cd /app
python -u blackhole_watcher.py 2>&1 | tee -a "$log_file"

echo "Blackhole has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300
