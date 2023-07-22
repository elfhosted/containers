FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:e92c2494b7c92e6a522a791440642fb25ce160c00906d7ac82efb8e5a5b20044 

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

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    curl -fsSL -o /tmp/nzbget.run \
      "https://github.com/nzbget/nzbget/releases/download/v${VERSION}/nzbget-${VERSION}-bin-linux.run" \
    && \
    sh /tmp/nzbget.run --destdir /app \
    && \
    curl -fsSL "https://curl.se/ca/cacert.pem" | sed '/^DST Root CA X3$/,/^-----END CERTIFICATE-----$/d;' > "/app/cacert.pem" \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

#hadolint ignore=DL3013,DL3018
RUN \
    apk add --no-cache ca-certificates p7zip python3 py3-lxml \
    && \
    apk add --no-cache --virtual .build-deps py3-pip \
    && \
    pip install --upgrade pip \
    && \
    pip install --upgrade \
      apprise \
      chardet \
      pynzbget \
      rarfile \
    && apk del --purge .build-deps \
    && rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/*

RUN curl -o /tmp/filebot.xz -L "https://get.filebot.net/filebot/FileBot_5.0.1/FileBot_5.0.1-portable.tar.xz" && \
    mkdir -p /opt/filebot && \
    tar xvf /tmp/filebot.xz -C /opt/filebot && \
    rm -rf /tmp/filebot.xz && \
    ln -s /opt/filebot/filebot.sh /usr/local/bin/filebot

USER 568
COPY ./apps/nzbget/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/nzbget/nzbget"
