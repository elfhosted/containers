############# importarr
FROM golang:1.20-bullseye AS importarr

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


ARG VERSION
FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d 

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    READARR__INSTANCE_NAME="Readarr" \
    READARR__BRANCH="${CHANNEL}" \
    READARR__PORT="8787" \
    READARR__ANALYTICS_ENABLED="False"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# for initial install
USER root
WORKDIR /app

#hadolint ignore=DL3018,DL3059
RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        curl \
        icu-libs \
        jq \
        libintl \
        nano \
        sqlite-libs \
        tzdata \
        xmlstarlet \
        postgresql-client \
    && \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='x64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "https://readarr.servarr.com/v1/update/${CHANNEL}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf /app/bin/Readarr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[funkypenguin](https://github.com/onedr0p)\n" "${CHANNEL}" "${VERSION}" > /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

COPY ./apps/readarr/entrypoint.sh /entrypoint.sh
COPY ./apps/readarr/database-backup.sh /database-backup.sh
COPY --from=importarr /app/importarr /usr/local/bin/importarr
RUN chmod +x /usr/local/bin/importarr

USER elfie:elfie
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Readarr/Readarr"