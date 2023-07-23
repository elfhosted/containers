FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8503f3a7ad329f24b843a2d1c2a12e95cebc5348f24052c277ed8c759fcb341b 

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates openjdk11-jre-headless python3
#hadolint ignore=DL3018,DL3059
RUN \
    curl -fsSL -o /tmp/nzbhydra2.zip \
        "https://github.com/theotherp/nzbhydra2/releases/download/v${VERSION}/nzbhydra2-${VERSION}-amd64-linux.zip" \
    && unzip -q /tmp/nzbhydra2.zip -d /app \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

USER 568
COPY ./apps/nzbhydra2/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/theotherp/nzbhydra2"
