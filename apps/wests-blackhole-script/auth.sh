#!/bin/bash

# Create a dummy tokens.json if it doesn't exist
if [ ! -f /config/tokens.json ]; then
    echo "[]" > /config/tokens.json
fi

if [[ -z "${OVERSEERR_HOST}" ]]; then
  echo "OVERSEERR_HOST env var is not set, sleeping..."
  sleep infinity
fi

cd /app
gunicorn --bind 0.0.0.0:32501 plex_authentication_wsgi:app