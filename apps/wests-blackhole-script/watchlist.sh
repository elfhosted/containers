#!/bin/bash

if [[ -z "${OVERSEERR_HOST}" ]]; then
  echo "OVERSEERR_HOST env var is not set, sleeping..."
  sleep infinity
fi

cd /app
python watchlist_runner.py