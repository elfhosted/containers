ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:8e6aef0cbeee351502e3323d5f056b5a41c962ab737e85b34878377a5ebe1e37

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
