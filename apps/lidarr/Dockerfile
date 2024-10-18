FROM ghcr.io/elfhosted/alpine:rolling@sha256:0782c9e41d6e1efe014e1081a12f9f25665aa9b18372de4bd9bb848ace53cceb 

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    LIDARR__INSTANCE_NAME="Lidarr" \
    LIDARR__BRANCH="${CHANNEL}" \
    LIDARR__PORT="8686" \
    LIDARR__ANALYTICS_ENABLED="False"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# for initial install
USER root

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates chromaprint ffmpeg icu-libs libintl sqlite-libs xmlstarlet
#hadolint ignore=DL3059
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='x64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "https://lidarr.servarr.com/v1/update/${LIDARR__BRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf \
        /app/bin/Lidarr.Update \
        /app/bin/fpcalc \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[geek-cookbook](https://github.com/geek-cookbook)" "${LIDARR__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

USER 568

COPY ./apps/lidarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/lidarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Lidarr/Lidarr"