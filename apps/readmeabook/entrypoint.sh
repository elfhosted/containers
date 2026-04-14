#!/bin/bash
set -e

# Run prisma schema push to create/migrate database tables
echo "Running database migrations..."
npx prisma db push --skip-generate --accept-data-loss 2>&1 || echo "Warning: prisma db push failed, database may not be ready yet"

# Start the app
exec node server.js
