FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 

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

ENV MYLAR3__PORT=8090

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# for initial install
USER root

RUN \
    curl -fsSL "https://github.com/mylar3/mylar3/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xzf - -C /app --strip-components=1 \
    && \
    chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

#hadolint ignore=DL3018,DL3013
RUN \
    # Keep py3-pip installed
    \
    apk add --no-cache \
        ca-certificates \
        python3 \
        py3-pip \ 
        # runtime tools
        jpeg \
        libwebp-tools \
        nodejs \
        zlib \
    && \
    apk add --no-cache --virtual=.build-deps \
        build-base \
        cargo \
        jpeg-dev \
        libffi-dev \
        libwebp-dev \
        musl-dev \
        openssl-dev \
        py3-cffi \
        python3-dev \
        zlib-dev \
    && \
    pip install --upgrade pip \
    && \
    pip install --upgrade --requirement /app/requirements.txt \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

USER 568
COPY ./apps/mylar3/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/mylar3/mylar3"
