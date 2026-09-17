#!/bin/sh
set -e

mkdir -p /tmp/next-cache

# Without it Kan starts but every auth and API request returns 500.
if [ -z "${BETTER_AUTH_SECRET}" ]; then
  echo "BETTER_AUTH_SECRET is not set; refusing to start" >&2
  exit 1
fi

# Apply database migrations (same drizzle journal/table as upstream's kan-migrate
# image), unless disabled because they are run elsewhere.
if [ "${KAN_SKIP_MIGRATIONS:-false}" != "true" ]; then
  if [ -z "${POSTGRES_URL}" ]; then
    echo "POSTGRES_URL is not set; refusing to start (the PGlite fallback is not supported in this image)" >&2
    exit 1
  fi
  node /db/migrate.mjs
fi

exec node /app/bootstrap.mjs
