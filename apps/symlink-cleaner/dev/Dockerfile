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
    && rm -rf /var/lib/apt/lists/*

# Copy dependency list and install
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn[eventlet]
COPY --chown=568:568 --from=cloner /source/symlink_cleaner.py /app/
COPY --chown=568:568 --from=cloner /source/event_manager.py /app/
COPY --chown=568:568 --from=cloner /source/templates/ /app/templates/
COPY --chown=568:568 --from=cloner /source/static/ /app/static/
COPY --chown=568:568 --from=cloner /source/gunicorn_config.py /app/
RUN chown -R 568:568 /app
USER 568
EXPOSE 5000
CMD ["gunicorn", "--config", "gunicorn_config.py", "symlink_cleaner:app"]