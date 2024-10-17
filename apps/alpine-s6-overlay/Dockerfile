FROM ghcr.io/elfhosted/alpine:rolling@sha256:3904ab32349188d94668bddf41e967d1c0daa0226b848abf35b235555cad2a59 

# Args
ARG VERSION

# Environment variables
ENV \
  PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
  HOME="/root" \
  TERM="xterm"

RUN \
  echo "**** Add s6 overlay ****" && \
  # Find arch for archive
  ARCH=$(uname -m) && \
  OVERLAY_ARCH="" && \
  [ "${ARCH}" = "x86_64" ] && OVERLAY_ARCH="x86_64" || true && \
  [ "${ARCH}" = "aarch64" ] && OVERLAY_ARCH="aarch64" || true && \
  [ "${ARCH}" = "armv7l" ] && OVERLAY_ARCH="armhf" || true && \
  # S6 scripts
  curl -fsS -O --output-dir /tmp/ -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-noarch.tar.xz" && \
  tar -C / -Jxpf "/tmp/s6-overlay-noarch.tar.xz" && \
  # S6 binary
  curl -fsS -O --output-dir /tmp/ -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.xz" && \
  tar -C / -Jxpf "/tmp/s6-overlay-${OVERLAY_ARCH}.tar.xz" && \
  # S6 symlinks
  curl -fsS -O --output-dir /tmp/ -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-symlinks-noarch.tar.xz" && \
  tar -C / -Jxpf "/tmp/s6-overlay-symlinks-noarch.tar.xz" && \
  curl -fsS -O --output-dir /tmp/ -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-symlinks-arch.tar.xz" && \
  tar -C / -Jxpf "/tmp/s6-overlay-symlinks-arch.tar.xz" && \
  echo "**** Cleanup ****" && \
  rm -rf \
    /tmp/*
