#!/bin/bash

DB_PATH="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
REAL_SCANNER="/usr/lib/plexmediaserver/Plex Media Scanner.real"
LOGFILE="/tmp/plex-skip.log"
ITEM_ID=""
ARGS=()

# === Parse arguments ===
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

# === Query for all media files for this item ===
mapfile -t FILES < <(sqlite3 "$DB_PATH" "
  SELECT mp.file
  FROM media_parts mp
  JOIN media_items mi ON mp.media_item_id = mi.id
  WHERE mi.metadata_item_id = $ITEM_ID;
")

# === Track known and valid files ===
ALL_VALID=1
KNOWN_PATHS=()

for FILE in "${FILES[@]}"; do
  if [[ ! -f "$FILE" ]]; then
    echo "$(date) - [$ITEM_ID] Known file missing: $FILE" | tee -a "$LOGFILE"
    ALL_VALID=0
    break
  fi

  ANALYZED=$(sqlite3 "$DB_PATH" "
    SELECT COUNT(*) FROM media_streams
    WHERE bitrate IS NOT NULL
      AND media_part_id IN (
        SELECT mp.id FROM media_parts mp
        JOIN media_items mi ON mp.media_item_id = mi.id
        WHERE mi.metadata_item_id = $ITEM_ID AND mp.file = '$FILE'
      );
  ")

  if [[ "$ANALYZED" -eq 0 ]]; then
    echo "$(date) - [$ITEM_ID] File not yet analyzed: $FILE" | tee -a "$LOGFILE"
    ALL_VALID=0
    break
  fi

  KNOWN_PATHS+=("$(realpath "$FILE")")
done

# === If all known files are present and analyzed, check for NEW files ===
if [[ "$ALL_VALID" -eq 1 ]]; then
  # Get parent directory
  DIR=$(dirname "${FILES[0]}")
  KNOWN_SET=$(printf '%s\n' "${KNOWN_PATHS[@]}" | sort)
  NEW_FOUND=0

  while IFS= read -r NEW_FILE; do
    NEW_REAL=$(realpath "$NEW_FILE")
    if ! grep -qxF "$NEW_REAL" <<< "$KNOWN_SET"; then
      echo "$(date) - [$ITEM_ID] Found untracked file in directory: $NEW_FILE" | tee -a "$LOGFILE"
      NEW_FOUND=1
      break
    fi
  done < <(find "$DIR" -maxdepth 1 -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \))

  if [[ "$NEW_FOUND" -eq 1 ]]; then
    exec "$REAL_SCANNER" "${ARGS[@]}"
  else
    echo "$(date) - [$ITEM_ID] All files accounted for and analyzed. Skipping." | tee -a "$LOGFILE"
    exit 0
  fi
else
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi
