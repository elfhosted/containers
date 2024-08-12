#!/bin/ash

cd /riven/src

echo "📺 Resetting database (until alembic migrations are fixed)..."
python main.py --hard_reset_db
PGPASSWORD=postgres psql -U postgres -d riven -h localhost -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
rm -rf /riven/alembic

echo "📺 Waiting for plex to be up..."
/usr/local/bin/wait-for -t 3600 plex:32400 -- echo "✅"

echo "👽 Waiting for zurg to be up..."
/usr/local/bin/wait-for -t 3600 zurg:9999 -- echo "✅"

echo "🎉 let's go!"
poetry run python3 main.py 

