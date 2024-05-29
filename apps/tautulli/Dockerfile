FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:f5e27001ebd22ad35f1a30d7d7e127b61273ae9c64666aee8ad37c522b7bae1a 

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1

ENV TAUTULLI_DOCKER="True"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN \
    curl -fsSL "https://github.com/Tautulli/Tautulli/archive/v${VERSION}.tar.gz" | tar xzf - -C /app --strip-components 1 \
    && \
    echo "v${VERSION}" > /app/version.txt \
    && \
    echo "${CHANNEL}" > /app/branch.txt \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

#hadolint ignore=DL3018,DL3013
RUN \
    apk add --no-cache ca-certificates python3 py3-lxml py3-openssl py3-setuptools \
    && \
    apk add --no-cache --virtual .build-deps py3-pip make gcc g++ python3-dev \
    && \
    pip install --upgrade pip \
    && \
    pip install --upgrade \
        plexapi \
        pycryptodomex \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

USER 568
COPY ./apps/tautulli/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Tautulli/Tautulli"
