ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:a5eb999bc123c17ac925490ab66e3d036ad6d4aeed87c8602aa9fd9399967145

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
