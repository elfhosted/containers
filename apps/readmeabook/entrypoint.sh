#!/bin/bash
set -e

# Sync the Prisma schema before starting the app. The database runs as a
# postgres sidecar in the same pod, so on a cold start the app container can
# win the race and reach this point before postgres is accepting connections.
# Retry until the push succeeds; fail hard (crashloop) if it never does, rather
# than starting the app against an empty schema and hiding a broken instance.
echo "Running database migrations..."
attempts=0
max_attempts=30
until npx prisma db push --skip-generate --accept-data-loss; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge "${max_attempts}" ]; then
        echo "ERROR: prisma db push failed after ${max_attempts} attempts, exiting"
        exit 1
    fi
    echo "prisma db push failed (attempt ${attempts}/${max_attempts}); database may not be ready, retrying in 3s..."
    sleep 3
done
echo "Database schema is up to date."

# Start the app
exec node server.js
