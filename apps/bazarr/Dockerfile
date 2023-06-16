FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:b612a392da0d0934ce4136552afadf0c33f00a0306dfa53758b5724f26212cb2 

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
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

# for initial install
USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    curl -fsSL -o /tmp/app.zip "https://github.com/morpheus65535/bazarr/releases/download/v${VERSION}/bazarr.zip" \
    && unzip -q /tmp/app.zip -d /app \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

#hadolint ignore=DL3018,DL3013
RUN \
    apk add --no-cache ca-certificates ffmpeg python3 py3-lxml py3-numpy py3-gevent py3-cryptography py3-setuptools \
    && \
    apk add --no-cache --virtual .build-deps py3-pip gcc python3-dev musl-dev \
    && \
    pip install --upgrade pip \
    && \
    pip install --upgrade \
        gevent-websocket \
        webrtcvad-wheels \
        pillow \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

USER 568
COPY ./apps/bazarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/morpheus65535/bazarr"

