#!/bin/bash

DB_PATH="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
REAL_SCANNER="/usr/lib/plexmediaserver/Plex Media Scanner.real"

# Extract --item value
ITEM_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --item)
      ITEM_ID="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# If no --item, just run the real scanner
if [[ -z "$ITEM_ID" ]]; then
  exec "$REAL_SCANNER" "$@"
fi

# Check analysis status
if sqlite3 "$DB_PATH" "SELECT 1 FROM media_analysis WHERE metadata_item_id = $ITEM_ID LIMIT 1;" | grep -q 1; then
  echo "Item $ITEM_ID already analyzed. Skipping."
  exit 0
else
  echo "Item $ITEM_ID not analyzed. Running scanner..."
  exec "$REAL_SCANNER" "$@"
fi
