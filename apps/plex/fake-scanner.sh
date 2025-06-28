#!/bin/bash

# === CONFIGURATION ===
DB_PATH="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
REAL_SCANNER="/usr/lib/plexmediaserver/Plex Media Scanner.real"
DAYS_THRESHOLD=30
LOGFILE="/config/Library/Application Support/Plex Media Server/Logs/analysis-skipper.log"

# === Parse --item argument ===
ITEM_ID=""
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --item)
      ITEM_ID="$2"
      ARGS+=("$1" "$2")
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

# === If no --item, delegate ===
if [[ -z "$ITEM_ID" ]]; then
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

NOW=$(date +%s)
THRESHOLD=$((DAYS_THRESHOLD * 86400))
RUN_SCANNER_REASON=""

# === Lookup media_analysis info ===
LAST_ANALYZED=$(sqlite3 "$DB_PATH" "SELECT media_analysis_date FROM media_analysis WHERE metadata_item_id = $ITEM_ID;")

# === Check if file exists on disk ===
FILE_PATH=$(sqlite3 "$DB_PATH" "
  SELECT mp.file
  FROM media_parts mp
  JOIN media_items mi ON mi.id = mp.media_item_id
  WHERE mi.metadata_item_id = $ITEM_ID
  LIMIT 1;
")

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  RUN_SCANNER_REASON="Media file not found on disk."
else
  if [[ -n "$LAST_ANALYZED" ]]; then
    AGE=$((NOW - LAST_ANALYZED))
    if (( AGE >= THRESHOLD )); then
      RUN_SCANNER_REASON="Item analyzed $((AGE / 86400)) days ago — too old."
    fi
  else
    RUN_SCANNER_REASON="Item has never been analyzed."
  fi
fi

# === Act on result ===
if [[ -n "$RUN_SCANNER_REASON" ]]; then
  echo "$(date) - Running scanner for item $ITEM_ID: $RUN_SCANNER_REASON" | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
else
  echo "$(date) - Skipping scanner for item $ITEM_ID: recently analyzed." | tee -a "$LOGFILE"
  exit 0
fi
