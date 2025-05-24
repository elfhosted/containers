# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/wizarrrr/wizarr.git /source

FROM python:3.12-alpine
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
# Install curl separately so it remains available for healthcheck
RUN apk add --no-cache curl tzdata

# Force our preferred user
RUN addgroup -S elfie --gid 568 && adduser -S elfie -G elfie --uid 568
USER 568

# Set up the working directory
WORKDIR /data
COPY --from=cloner /source/. /data

# Run uv sync
RUN uv sync --locked

#Healthcheck 
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fs http://localhost:5690/health || exit 1

EXPOSE 5690

COPY --from=cloner /source/wizard_steps /opt/default_wizard_steps

CMD uv run gunicorn \
    --config gunicorn.conf.py \
    --preload \
    --workers 4 \
    --bind 0.0.0.0:5690 \
    --umask 007 \
    run:app