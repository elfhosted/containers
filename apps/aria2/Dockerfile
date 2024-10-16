ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:1ab7fc4fac80c3313d9c1178b32429c2a92644d93369a145ee497d86dd8d9bbc

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
