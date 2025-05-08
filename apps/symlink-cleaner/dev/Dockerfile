# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://$ZURG_GH_CREDS@github.com/bsm-elf/symlink-cleaner.git /source

FROM python:3.12-slim as builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn[gevent]

# Final stage
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=symlink_cleaner.py \
    FLASK_ENV=production \
    GUNICORN_WORKERS=2

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

COPY --chown=568:568 --from=cloner /source/symlink_cleaner.py /app/
COPY --chown=568:568 --from=cloner /source/event_manager.py /app/
COPY --chown=568:568 --from=cloner /source/templates/ /app/templates/
COPY --chown=568:568 --from=cloner /source/static/ /app/static/
COPY --chown=568:568 --from=cloner /source/file_watcher.py /app/
COPY --chown=568:568 --from=cloner /source/gunicorn_config.py /app/

# Create directories with proper permissions
RUN mkdir -p /app/config /app/config/logs \
    /storage/realdebrid-zurg/__all__ \
    /storage/symlinks/anime_movies \
    /storage/symlinks/anime_shows \
    /storage/symlinks/movies \
    /storage/symlinks/movies-4k \
    /storage/symlinks/series \
    /storage/symlinks/series-4k \
    /storage/symlinks/shows \
    /dummy/debrid_mount /dummy/symlink_dir && \
    echo '{"debrid_mount": "/dummy/debrid_mount", "symlink_dirs": ["/dummy/symlink_dir"], "mode": "repair", "monitor_mode": "repair", "enable_monitoring": false, "dry_run": false, "version": "1.4.8", "media_servers": {"plex": {"enabled": false, "host": "", "library_id": "", "token": ""}, "emby": {"enabled": false, "host": "", "api_key": ""}, "jellyfin": {"enabled": false, "host": "", "api_key": ""}}, "clean_batch_size": 100, "clean_delay": 1, "full_scan_interval": 21600, "populate_batch_size": 5000, "polling_interval": 1.0}' > /app/config/config.json && \
    chown -R 568:568 /app /dummy /storage && \
    chmod -R 775 /app/config && \
    ls -l /app/templates/ && test -f /app/templates/index.html || (echo "ERROR: index.html not found" && exit 1)

USER 568
EXPOSE 5000

# Kubernetes volume mounts:
# - /app/config: Persistent volume for config.json, symlinks.db, and logs
# - /storage/realdebrid-zurg/__all__: Debrid mount
# - /storage/symlinks/*: Symlink directories
HEALTHCHECK --interval=30s --timeout=10s --start-period=600s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

CMD ["gunicorn", "--config", "gunicorn_config.py", "symlink_cleaner:application"]