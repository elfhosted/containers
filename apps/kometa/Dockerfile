# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Kometa-Team/Kometa.git /source

# syntax=docker/dockerfile:1

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3d8693e2e68a277e14e96594381f8b8620c81ada3827babb842faeaae607693f 

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KOMETA_VERSION

ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    build-base \
    libffi-dev \
    libxml2-dev \
    libzen-dev \
    python3-dev \
    py3-pip && \
  apk add  -U --update --no-cache \
    grep \
    libjpeg \
    libxslt \
    ttyd \
    tmux \
    python3 && \
  if [ -z ${KOMETA_VERSION+x} ]; then \
    KOMETA_VERSION=$(curl -s https://api.github.com/repos/Kometa-Team/Kometa/releases \
    | jq -r 'first(.[]) | .tag_name'); \
  fi && \
  mkdir -p /app/kometa && \
  curl -o \
    /tmp/kometa.tar.gz -L \
    "https://github.com/Kometa-Team/Kometa/archive/${KOMETA_VERSION}.tar.gz" && \
  tar xf \
    /tmp/kometa.tar.gz -C \
    /app/kometa --strip-components=1 && \
  cd /app/kometa && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ -r requirements.txt && \
  pip cache purge && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
# Add the components for tmux-in-wetty
COPY --chown=568:568 apps/kometa/kometa.sh /
COPY --chown=568:568 apps/kometa/launch-tmux.sh /
COPY --chown=568:568 apps/kometa/entrypoint.sh /
COPY --chown=568:568 apps/kometa/restricted.tmux.conf /

# ports and volumes
VOLUME /config

ENTRYPOINT ["/entrypoint.sh"]