ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
