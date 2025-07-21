#!/bin/bash

DB_PATH="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
REAL_SCANNER="/usr/lib/plexmediaserver/Plex Media Scanner.real"
LOGFILE="/tmp/analysis-skipper.log"

ITEM_ID=""
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --item)
      if [[ "$2" =~ ^[0-9]+$ ]]; then
        ITEM_ID="$2"
      else
        echo "$(date) - [$2] Multiple IDs detected or invalid format. Passing through to real scanner." | tee -a "$LOGFILE"
        exec "$REAL_SCANNER" "$@"
      fi
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

# Default SKIP_ANALYSIS_DURATION to 365 days if not set
SKIP_ANALYSIS_DURATION="${SKIP_ANALYSIS_DURATION:-365}"

# Retry-safe SQLite query helper
retry_sqlite() {
  local db="$1"
  local sql="$2"
  local retries=5
  local delay=0.5
  local attempt=0
  local result=""

  while [[ $attempt -lt $retries ]]; do
    result=$(sqlite3 "$db" "$sql" 2>/tmp/sqlite-error.log) && break
    if grep -q "database is locked" /tmp/sqlite-error.log; then
      sleep "$delay"
      attempt=$((attempt + 1))
    else
      cat /tmp/sqlite-error.log >&2
      break
    fi
  done

  echo "$result"
}

# Step 1: Get all media file paths for the item
MEDIA_FILES=$(retry_sqlite "$DB_PATH" "
  SELECT mp.file
  FROM media_parts mp
  JOIN media_items mi ON mi.id = mp.media_item_id
  WHERE mi.metadata_item_id = $ITEM_ID;
")

if [[ -z "$MEDIA_FILES" ]]; then
  echo "$(date) - [$ITEM_ID] No media files found in DB. Running scanner." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

# Step 2: Determine the latest mod time among known media files and collect parent dirs
LATEST_KNOWN_MOD=0
PARENT_DIRS=()

while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  mod_time=$(stat -c %Y "$path")
  [[ "$mod_time" -gt "$LATEST_KNOWN_MOD" ]] && LATEST_KNOWN_MOD=$mod_time
  dir=$(dirname "$path")
  PARENT_DIRS+=("$dir")
done <<< "$MEDIA_FILES"

# Step 3: Check each unique parent folder for newer video files
UNIQUE_DIRS=($(printf "%s\n" "${PARENT_DIRS[@]}" | sort -u))

for dir in "${UNIQUE_DIRS[@]}"; do
  dir_mod_time=$(find "$dir" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.ts" \) \
    -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)
  if [[ -n "$dir_mod_time" && "$dir_mod_time" -gt "$LATEST_KNOWN_MOD" ]]; then
    echo "$(date) - [$ITEM_ID] New movie file(s) found in '$dir' (folder mod $dir_mod_time > known mod $LATEST_KNOWN_MOD). Re-analyzing." | tee -a "$LOGFILE"
    exec "$REAL_SCANNER" "${ARGS[@]}"
  fi
done

# Step 4: Check if already analyzed
ANALYZED_STREAMS=$(retry_sqlite "$DB_PATH" "
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

# Step 5: Time-based expiry of analysis
if [[ "$ANALYZED_STREAMS" -gt 0 ]]; then
  NOW=$(date +%s)
  CUTOFF=$((NOW - SKIP_ANALYSIS_DURATION * 86400))

  LAST_ANALYZED=$(retry_sqlite "$DB_PATH" "
    SELECT MAX(CASE 
      WHEN mp.updated_at > 0 THEN mp.updated_at
      ELSE mp.created_at
    END)
    FROM media_parts mp
    JOIN media_items mi ON mi.id = mp.media_item_id
    WHERE mi.metadata_item_id = $ITEM_ID;
  ")

  if [[ -n "$LAST_ANALYZED" && "$LAST_ANALYZED" -lt "$CUTOFF" ]]; then
    echo "$(date) - [$ITEM_ID] Last analysis was $(date -d @$LAST_ANALYZED). Exceeds SKIP_ANALYSIS_DURATION ($SKIP_ANALYSIS_DURATION days). Re-analyzing." | tee -a "$LOGFILE"
    exec "$REAL_SCANNER" "${ARGS[@]}"
  fi
fi

# Step 6: Check for missing video stream (which causes 'Unknown' quality in Plex)
MISSING_QUALITY_COUNT=$(retry_sqlite "$DB_PATH" "
  SELECT COUNT(*)
  FROM media_parts mp
  JOIN media_items mi ON mi.id = mp.media_item_id
  WHERE mi.metadata_item_id = $ITEM_ID
    AND mp.id NOT IN (
      SELECT DISTINCT media_part_id FROM media_streams
    );
")



if [[ "$MISSING_QUALITY_COUNT" -gt 0 ]]; then
  echo "$(date) - [$ITEM_ID] Found $MISSING_QUALITY_COUNT file(s) with missing video quality info. Re-analyzing." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi

# Final decision
if [[ "$ANALYZED_STREAMS" -gt 0 ]]; then
  echo "$(date) - [$ITEM_ID] Already analyzed ($ANALYZED_STREAMS stream(s) with bitrate). Skipping." | tee -a "$LOGFILE"
  exit 0
else
  echo "$(date) - [$ITEM_ID] No bitrate info found. Running scanner." | tee -a "$LOGFILE"
  exec "$REAL_SCANNER" "${ARGS[@]}"
fi
