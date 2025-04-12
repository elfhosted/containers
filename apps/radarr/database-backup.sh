#!/bin/sh

# Configuration
BACKUP_DIR="/backup/"
PGPASSWORD: radarr
PGDATABASE: postgres
PGUSER: radarr
PGHOST: localhost

RETENTION_DAYS=7
DATABASES="radarr_main radarr_logs"

backup_db() {
  DB_NAME="$1"
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  FILENAME="${DB_NAME}_backup_${TIMESTAMP}.sql.gz"
  FILEPATH="${BACKUP_DIR}/${FILENAME}"

  echo "[INFO] Backing up ${DB_NAME} to ${FILENAME}"
  pg_dump "$DB_NAME" | gzip > "$FILEPATH"

  if [ $? -eq 0 ]; then
    echo "[INFO] Backup of ${DB_NAME} successful"
  else
    echo "[ERROR] Backup of ${DB_NAME} failed"
  fi
}

# Loop forever
while true; do
  for DB in $DATABASES; do
    backup_db "$DB"
  done

  echo "[INFO] Cleaning up old backups"
  find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

  echo "[INFO] Sleeping for 24 hours..."
  sleep 86400
done