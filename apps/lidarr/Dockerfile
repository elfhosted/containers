############# importarr
FROM golang:1.24-bullseye AS importarr

# Install necessary build tools and SQLite dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc6-dev sqlite3 libsqlite3-dev musl musl-dev musl-tools gcc-multilib git && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/musl-gcc /usr/bin/x86_64-linux-musl-gcc

# Set environment variables
ENV CGO_ENABLED=1 GOOS=linux GOARCH=amd64

RUN git clone https://github.com/elfhosted/importarr.git /app

# Set the working directory
WORKDIR /app

# Copy the Go module files and download dependencies
RUN go mod download

# Build the Go binary
RUN go build -ldflags="-linkmode external -extldflags -static" -o importarr cmd/main.go

FROM ghcr.io/elfhosted/alpine-edge:rolling@sha256:31272a3b40aa1d0e1471d0429b99ac6ef9a35d5c54aa584881b54924043f83bc

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
RUN apk add --no-cache ca-certificates chromaprint ffmpeg icu-libs libintl sqlite-libs xmlstarlet postgresql-client
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

COPY --from=importarr /app/importarr /usr/local/bin/importarr
RUN chmod +x /usr/local/bin/importarr

USER 568

COPY ./apps/lidarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/lidarr/entrypoint.sh /entrypoint.sh
COPY ./apps/lidarr/database-backup.sh /database-backup.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Lidarr/Lidarr"