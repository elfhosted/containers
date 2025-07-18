#!/bin/bash

while true; do
  # Run the mounts.sh script with a 2-second timeout
  if ! timeout 2s /scripts/mounts.sh; then
    echo "[mounts-check] mounts.sh failed or timed out. Restarting plex service..."
    /command/s6-svc -r /run/service/plex
  fi

  # Run the wait-for-urls.sh script with a 2-second timeout
  if ! timeout 2s /scripts/wait-for-urls.sh; then
    echo "[wait-for-urls-check] wait-for-urls.sh failed or timed out. Restarting plex service..."
    /command/s6-svc -r /run/service/plex
  fi

  sleep 300  # Wait 5 minutes before next check
done