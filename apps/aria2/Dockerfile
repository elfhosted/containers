ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:613831c1627a38d1b2e3b91870ff4fd8537548e2911ebc9b20c53ea0c012aea6

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
