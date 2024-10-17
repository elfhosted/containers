ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:4dccd868574f5595117642045ab574ed4ca628b43c8680ed253c422de1362a9b

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
