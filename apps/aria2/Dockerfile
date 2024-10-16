ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3901b78e8dac885868634a530283571e15d955b70d4a4bff649c25fb6053f8d1

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
