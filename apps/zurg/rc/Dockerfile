# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://$ZURG_GH_CREDS@github.com/debridmediamanager/zurg:${VERSION}.git /source

FROM golang:1-alpine AS builder
ARG BuiltAt
ARG GitCommit
ARG Version
WORKDIR /app
COPY --from=cloner /source/. .
RUN apk add --no-cache bash git go gcc musl-dev curl fuse libxml2-utils
RUN go build -ldflags "-s -w -X 'github.com/debridmediamanager/zurg/internal/version.BuiltAt=$BuiltAt' -X 'github.com/debridmediamanager/zurg/internal/version.GitCommit=$GitCommit' -X 'github.com/debridmediamanager/zurg/internal/version.Version=$Version'" -o zurg ./cmd/zurg

FROM ghcr.io/geek-cookbook/alpine:3.19.1@sha256:9c7e1a891b92b261c034a8d9b77b19dd007cc5398ab958282fd9a152fc4c9b46
WORKDIR /app

COPY --from=builder /app/zurg .
COPY config.example.yml /app/config.yml
# Install runtime dependencies and configure FUSE
RUN apk add curl python3 libxml2-utils

ENTRYPOINT ["./zurg"]
