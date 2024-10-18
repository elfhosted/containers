ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:d22922949b86a1ea8107ccd25893fc65024d566408d56c533620e8b4f9b28f64

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
