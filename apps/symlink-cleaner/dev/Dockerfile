# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://$ZURG_GH_CREDS@github.com/bsm-elf/symlink-cleaner.git /source

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=symlink_cleaner.py \
    FLASK_ENV=production

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn[gevent]

COPY --chown=568:568 --from=cloner /source/symlink_cleaner.py /app/
COPY --chown=568:568 --from=cloner /source/event_manager.py /app/
COPY --chown=568:568 --from=cloner /source/templates/ /app/templates/
COPY --chown=568:568 --from=cloner /source/static/ /app/static/
COPY --chown=568:568 --from=cloner /source/file_watcher.py /app/

# Create default config directory and file if not mounted, plus storage paths
RUN mkdir -p /app/config /storage/realdebrid-zurg/__all__ \
    /storage/symlinks/anime_movies /storage/symlinks/anime_shows \
    /storage/symlinks/movies /storage/symlinks/movies-4k \
    /storage/symlinks/series /storage/symlinks/series-4k \
    /storage/symlinks/shows && \
    echo '{"debrid_mount": "/dummy/debrid_mount", "symlink_dirs": ["/dummy/symlink_dir"], "mode": "repair", "monitor_mode": "repair", "enable_monitoring": false, "dry_run": false, "version": "1.4.7", "media_servers": {"plex": {"enabled": false, "host": "", "library_id": "", "token": ""}, "emby": {"enabled": false, "host": "", "api_key": ""}, "jellyfin": {"enabled": false, "host": "", "api_key": ""}}, "clean_batch_size": 100, "clean_delay": 1}' > /app/config/config.json && \
    mkdir -p /dummy/debrid_mount /dummy/symlink_dir && \
    chown -R 568:568 /app /dummy /storage && \
    ls -l /app/templates/ && test -f /app/templates/index.html || (echo "ERROR: index.html not found" && exit 1)

USER 568
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=600s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

CMD ["gunicorn", "--worker-class", "gevent", "--workers", "2", "--bind", "0.0.0.0:5000", "symlink_cleaner:application"]