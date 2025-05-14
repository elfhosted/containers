FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/sirrobot01/debrid-blackhole.git  /source

# Stage 1: Build binaries
FROM --platform=$BUILDPLATFORM golang:1.23-alpine as builder

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
    -ldflags="-w -s -X github.com/sirrobot01/debrid-blackhole/pkg/version.Version=${VERSION} -X github.com/sirrobot01/debrid-blackhole/pkg/version.Channel=${CHANNEL}" \
    -o /blackhole

# Build healthcheck (optimized)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-w -s" \
    -o /healthcheck cmd/healthcheck/main.go

# Stage 2: Create directory structure
FROM alpine:3.19 as dirsetup
RUN mkdir -p /app/logs && \
    chmod 777 /app/logs && \
    touch /app/logs/decypharr.log && \
    chmod 666 /app/logs/decypharr.log

# Stage 3: Final image
# need a shell for debugging for now
# FROM gcr.io/distroless/static-debian12:elfie
FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c3dbccc25e349861a983e12ab7c2b2f14a6365dacbe2c500a819dd103164af6

LABEL version = "${VERSION}-${CHANNEL}"

LABEL org.opencontainers.image.source = "https://github.com/sirrobot01/debrid-blackhole"
LABEL org.opencontainers.image.title = "debrid-blackhole"
LABEL org.opencontainers.image.authors = "sirrobot01"
LABEL org.opencontainers.image.documentation = "https://github.com/sirrobot01/debrid-blackhole/blob/main/README.md"

# Copy binaries
COPY --from=builder --chown=elfie:elfie /blackhole /usr/bin/blackhole
COPY --from=builder --chown=elfie:elfie /healthcheck /usr/bin/healthcheck

# Copy pre-made directory structure
COPY --from=dirsetup --chown=elfie:elfie /app /app

# Metadata
ENV LOG_PATH=/app/logs
EXPOSE 8181 8282
VOLUME ["/app"]
USER elfie:elfie

# So that the app will start for goss tests
COPY apps/decypharr/config.json /config/

HEALTHCHECK CMD ["/usr/bin/healthcheck"]

# We need config to go to /config so that we can mount logs to /app/logs
CMD ["/usr/bin/blackhole", "--config", "/config"]