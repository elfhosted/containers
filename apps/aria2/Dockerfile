ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
