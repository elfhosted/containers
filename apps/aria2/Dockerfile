ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:e12c70c7e860b2b7b86be80ea3f06b9d70cd6e82cb48d6d89b5cb5d62b1d2cec

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
