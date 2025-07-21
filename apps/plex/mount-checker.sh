#!/bin/bash

while true; do
  echo "[mount-checker] Starting mount and URL checks at $(date)"

  # Run the mounts.sh script with a 2-second timeout, suppress output
  if ! timeout 2s /scripts/mounts.sh &>/dev/null; then
    echo "[mounts-check] mounts.sh failed or timed out at $(date). Restarting plex service..."
    /command/s6-svc -r /run/service/plex
  else
    echo "[mounts-check] mounts.sh succeeded at $(date)"
  fi

  # Run the wait-for-urls.sh script with a 2-second timeout, suppress output
  if ! timeout 2s /scripts/wait-for-urls.sh &>/dev/null; then
    echo "[wait-for-urls-check] wait-for-urls.sh failed or timed out at $(date). Restarting plex service..."
    /command/s6-svc -r /run/service/plex
  else
    echo "[wait-for-urls-check] wait-for-urls.sh succeeded at $(date)"
  fi

  echo "[mount-checker] Sleeping for 5 minutes..."
  sleep 300  # Wait 5 minutes before next check
done