ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:4dfbee4095cde8a0d6af3e934f7be7aa64ec3901dc529cb4b455d612ce75aee7

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
