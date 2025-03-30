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

# Copy dependency list and install
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn[eventlet]

COPY --chown=568:568 --from=cloner /source/ssymlink_cleaner.py /app/
COPY --chown=568:568 --from=cloner /source/sevent_manager.py /app/
COPY --chown=568:568 --from=cloner /source/stemplates/ /app/templates/
COPY --chown=568:568 --from=cloner /source/sstatic/ /app/static/
COPY --chown=568:568 --from=cloner /source/gunicorn_config.py /app/

# Create default config directory and file if not mounted
RUN mkdir -p /app/config && \
    echo '{"debrid_mount": "/dummy/debrid_mount", "symlink_dirs": ["/dummy/symlink_dir"], "mode": "repair", "monitor_mode": "repair", "enable_monitoring": false, "dry_run": false, "version": "1.4.7", "media_servers": {"plex": {"enabled": false, "host": "", "library_id": "", "token": ""}, "emby": {"enabled": false, "host": "", "api_key": ""}, "jellyfin": {"enabled": false, "host": "", "api_key": ""}}, "clean_batch_size": 100, "clean_delay": 1}' > /app/config/config.json && \
    mkdir -p /dummy/debrid_mount /dummy/symlink_dir && \
    chown -R 568:568 /app /dummy

USER 568
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

CMD ["gunicorn", "--config", "gunicorn_config.py", "symlink_cleaner:app"]