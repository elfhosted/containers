FROM alpine:latest as cloner

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/ffprobe-shim.git /source

FROM golang:1.24-alpine AS builder

# Install git for fetching dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY --from=cloner /source/go.mod go.sum* ./

# Initialize module if go.mod doesn't exist
RUN if [ ! -f go.mod ]; then \
    go mod init ffprobe-shim && \
    go get github.com/middelink/go-parse-torrent-name; \
    else \
    go get github.com/middelink/go-parse-torrent-name; \
    fi

# Copy source code
COPY --from=cloner /source/*.go ./

# Add a build argument to bust the cache
ARG CACHE_BUSTER=1
RUN echo "Cache Buster: $CACHE_BUSTER" && CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o ffprobe

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
    RADARR__INSTANCE_NAME="Radarr" \
    RADARR__BRANCH="${CHANNEL}" \
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

RUN  mv /app/bin/ffprobe /app/bin/ffprobe-real
COPY --from=builder /app/ffprobe /app/bin/ffprobe
COPY --from=importarr /app/importarr /usr/local/bin/importarr
RUN chmod +x /usr/local/bin/importarr

USER 568

ENV COMPlus_EnableDiagnostics=0
ENV REAL_FFPROBE_PATH=/app/bin/ffprobe-real

COPY ./apps/radarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/radarr/entrypoint.sh /entrypoint.sh
COPY ./apps/radarr/elf-import.sh /elf-import.sh
COPY ./apps/radarr/database-backup.sh /database-backup.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Radarr/Radarr"