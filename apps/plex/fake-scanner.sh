#!/bin/bash

DB_PATH="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
REAL_SCANNER="/usr/lib/plexmediaserver/Plex Media Scanner.real"
LOGFILE="/tmp/analysis-skipper.log"

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

if [[ -z "$ITEM_ID" ]]; then
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

FILE_PATH=$(sqlite3 "$DB_PATH" "
  SELECT mp.file
  FROM media_parts mp
  JOIN media_items mi ON mi.id = mp.media_item_id
  WHERE mi.metadata_item_id = $ITEM_ID
  LIMIT 1;
")

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  echo "$(date) - [$ITEM_ID] File not found on disk. Running scanner." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

FILE_MOD_TIME=$(stat -c %Y "$FILE_PATH")
DIR_NEWEST_MOD=$(find "$FILE_DIR" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)

if [[ -n "$DIR_NEWEST_MOD" && "$DIR_NEWEST_MOD" -gt "$FILE_MOD_TIME" ]]; then
  echo "$(date) - [$ITEM_ID] New file(s) detected in '$FILE_DIR'. Re-analyzing." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

# Check if already analyzed
ANALYZED_STREAMS=$(sqlite3 "$DB_PATH" "
  SELECT COUNT(*)
  FROM media_streams
  WHERE bitrate IS NOT NULL
    AND media_part_id IN (
      SELECT mp.id
      FROM media_parts mp
      JOIN media_items mi ON mi.id = mp.media_item_id
      WHERE mi.metadata_item_id = $ITEM_ID
    );
")

if [[ "$ANALYZED_STREAMS" -gt 0 ]]; then
  echo "$(date) - [$ITEM_ID] Already analyzed ($ANALYZED_STREAMS stream(s) with bitrate). Skipping." | tee -a "$LOGFILE"
  exit 0
else
  echo "$(date) - [$ITEM_ID] No bitrate info found. Running scanner." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi
