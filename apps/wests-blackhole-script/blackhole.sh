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

# run the script
cd /app
python blackhole_watcher.py
echo "Blackhole has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300