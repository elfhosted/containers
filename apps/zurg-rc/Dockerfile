# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://$ZURG_GH_CREDS@github.com/debridmediamanager/zurg.git /source

FROM golang:1-alpine AS builder
ARG BuiltAt
ARG GitCommit
ARG Version
WORKDIR /app
COPY --from=cloner /source/. .
RUN apk add --no-cache bash git go gcc musl-dev curl fuse libxml2-utils
RUN go build -ldflags "-s -w -X 'github.com/debridmediamanager/zurg/internal/version.BuiltAt=$BuiltAt' -X 'github.com/debridmediamanager/zurg/internal/version.GitCommit=$GitCommit' -X 'github.com/debridmediamanager/zurg/internal/version.Version=$Version'" -o zurg ./cmd/zurg

FROM ghcr.io/elfhosted/alpine:3.19.4@sha256:4293c1100c1dc1839feaac751f1066cbf8543701212e7abbc833bf8cb2ecd2b6
WORKDIR /app

COPY --from=builder /app/zurg .
COPY --from=cloner /source/config.example.yml /config/config.yml

# Install runtime dependencies and configure FUSE
RUN apk add curl python3 libxml2-utils ffmpeg

COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]