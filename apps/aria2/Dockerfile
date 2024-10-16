ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:05a4a21c5a2f0a133ba338fe802e0565bd2b9b0da7aac7a254df2e5833511900

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
