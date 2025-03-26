FROM ghcr.io/elfhosted/ffprobe-shim:rolling as ffprobe-shim

FROM ghcr.io/elfhosted/alpine-edge:rolling@sha256:31272a3b40aa1d0e1471d0429b99ac6ef9a35d5c54aa584881b54924043f83bc

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    SONARR__INSTANCE_NAME="Sonarr" \
    SONARR__BRANCH="${CHANNEL}" \
    SONARR__PORT="8989" \
    SONARR__ANALYTICS_ENABLED="False"

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
    curl -fsSL "https://services.sonarr.tv/v1/update/${SONARR__BRANCH}/download?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app --strip-components=1 \
    && \
    rm -rf \
        /app/Sonarr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[geek-cookbook](https://github.com/geek-cookbook)" "${SONARR__BRANCH}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

# Try to overwrite ffprobe with shim
RUN mv /app/ffprobe /app/ffprobe-real
COPY --from=ffprobe-shim /app/ffprobe-shim /app/ffprobe

USER 568

COPY ./apps/sonarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/sonarr/entrypoint.sh /entrypoint.sh
COPY ./apps/sonarr/elf-import.sh /elf-import.sh

ENV PATH="/app:$PATH"

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.title="${SONARR__INSTANCE_NAME} (${SONARR__BRANCH})"
