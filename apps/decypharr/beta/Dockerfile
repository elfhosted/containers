FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache git && \
    git clone -b beta https://github.com/sirrobot01/debrid-blackhole.git  /source

# Stage 1: Build binaries
FROM --platform=$BUILDPLATFORM golang:1.24-alpine as builder

ARG TARGETOS
ARG TARGETARCH
ARG VERSION=0.0.0
ARG CHANNEL=dev

WORKDIR /app

COPY --from=cloner /source/go.mod /source/go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download -x

COPY --from=cloner /source/. .

# Build main binary
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath \
    -ldflags="-w -s -X github.com/sirrobot01/decypharr/pkg/version.Version=${VERSION} -X github.com/sirrobot01/decypharr/pkg/version.Channel=${CHANNEL}" \
    -o /decypharr

# Build healthcheck (optimized)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-w -s" \
    -o /healthcheck cmd/healthcheck/main.go

# Stage 2: Create directory structure
FROM alpine:3.19 as dirsetup
RUN mkdir -p /app/logs && \
    mkdir -p /app/cache && \
    chmod 777 /app/logs && \
    touch /app/logs/decypharr.log && \
    chmod 666 /app/logs/decypharr.log

# Stage 3: Final image
# need a shell for debugging for now
# FROM gcr.io/distroless/static-debian12:elfie
FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d

LABEL version = "${VERSION}-${CHANNEL}"

LABEL org.opencontainers.image.source = "https://github.com/sirrobot01/decypharr"
LABEL org.opencontainers.image.title = "decypharr"
LABEL org.opencontainers.image.authors = "sirrobot01"
LABEL org.opencontainers.image.documentation = "https://github.com/sirrobot01/decypharr/blob/main/README.md"

# Copy binaries
COPY --from=builder --chown=elfie:elfie /decypharr /usr/bin/decypharr
COPY --from=builder --chown=elfie:elfie /healthcheck /usr/bin/healthcheck

# Copy pre-made directory structure
COPY --from=dirsetup --chown=elfie:elfie /app /app

# Metadata
ENV LOG_PATH=/app/logs
EXPOSE 8282
VOLUME ["/app"]
USER elfie:elfie

# So that the app will start for goss tests
COPY --chown=elfie:elfie apps/decypharr/config.json /config/

CMD ["/usr/bin/decypharr", "--config", "/app"]