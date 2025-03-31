FROM ghcr.io/elfhosted/ffprobe-shim:rolling@sha256:46ef065532f5182fb716b2714b8c59151669ab1fe6744a434ed71d1c0e38f12f as ffprobe-shim 

FROM ghcr.io/elfhosted/alpine-edge:rolling@sha256:31272a3b40aa1d0e1471d0429b99ac6ef9a35d5c54aa584881b54924043f83bc

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    RADARR__INSTANCE_NAME="Radarr" \
    RADARR__BRANCH="main" \
    RADARR__PORT="7878" \
    RADARR__ANALYTICS_ENABLED="False"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# for initial install
USER root

#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates icu-libs libintl sqlite-libs xmlstarlet postgresql-client pgloader sqlite
#hadolint ignore=DL3059
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='x64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "https://radarr.servarr.com/v1/update/${RADARR__BRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf \
        /app/bin/Radarr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[onedr0p](https://github.com/onedr0p)\n" "${RADARR__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*


# Try using shim
RUN mv /app/bin/ffprobe /app/bin/ffprobe.real
COPY --from=ffprobe-shim /usr/bin/ffprobe /app/bin/ffprobe
ENV REAL_FFPROBE=/app/bin/ffprobe.real

USER 568

ENV COMPlus_EnableDiagnostics=0

COPY ./apps/radarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/radarr/entrypoint.sh /entrypoint.sh
COPY ./apps/radarr/elf-import.sh /elf-import.sh


CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Radarr/Radarr"