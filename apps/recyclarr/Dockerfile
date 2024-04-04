FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://github.com/recyclarr/recyclarr.git /source

FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine as base

FROM base AS base-arm
ENV RUNTIME=linux-musl-arm

FROM base AS base-arm64
ENV RUNTIME=linux-musl-arm64

FROM base AS base-amd64
ENV RUNTIME=linux-musl-x64

FROM base-amd64 AS final

ENV RUNTIME=linux-musl-x64
# Required by environment and/or dotnet
ENV PATH="${PATH}:/app/recyclarr" \
    RECYCLARR_APP_DATA=/config \
    CRON_SCHEDULE="@daily" \
    RECYCLARR_CREATE_CONFIG=false

RUN set -ex; \
    apk add --no-cache bash tzdata supercronic git tini; \
    mkdir -p /config && chown 1000:1000 /config;

COPY --from=cloner /source/artifacts/$RUNTIME /app/recyclarr/
COPY --chmod=555 --from=cloner /source/scripts/prod/*.sh /

USER 1000:1000
VOLUME /config

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]