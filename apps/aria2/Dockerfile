ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:47653e2a1a8ab61d4666972d380ed6efa1ece6fb6dd62990f8992afe23fd41e1

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
