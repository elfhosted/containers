ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:523b82a80cbc42de1b430e84afff4c09b377387d3d0fb2e43ba7317d49d84607

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
