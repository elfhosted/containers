FROM ghcr.io/elfhosted/alpine:rolling@sha256:3d8693e2e68a277e14e96594381f8b8620c81ada3827babb842faeaae607693f 

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

ENV PIP_BREAK_SYSTEM_PACKAGES=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# We need to be root for the build
USER root
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    curl-dev \
    libffi-dev \
    libjpeg-turbo-dev \
    openssl-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    curl \
    ffmpeg \
    libjpeg-turbo \
    p7zip \
    py3-pip \
    python3 \
    sqlite \
    tesseract-ocr && \
  echo "**** install pyload ****" && \
  if [ -z ${VERSION+x} ]; then \
    PYLOAD="pyload-ng[all]"; \
  else \
    PYLOAD="pyload-ng[all]==${VERSION}"; \
  fi && \
  pip3 install -U pip setuptools wheel && \
  pip install -U --find-links https://wheel-index.linuxserver.io/alpine-3.16/ \
    "${PYLOAD}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cache \
    ${HOME}/.cargo


# ports and volumes
EXPOSE 80
VOLUME /config


COPY ./apps/pyload-ng/entrypoint.sh /entrypoint.sh

# drop to elfie user
USER 568

CMD ["/entrypoint.sh"]