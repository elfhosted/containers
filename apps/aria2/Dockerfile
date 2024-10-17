ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:79517c8ea74d1e7e4c0bb9347de6f63acac10bd23578c037d6389e28f46b6b92

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
