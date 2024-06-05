ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:f5e27001ebd22ad35f1a30d7d7e127b61273ae9c64666aee8ad37c522b7bae1a

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
