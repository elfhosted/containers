ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:bf24106fa491cfbf45ffd9d7f51d2c427eecf8e540df6ab6fa1693b10d1d7105

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
