ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:5c66af1589e882360456b34d780eceaf3ea134a52b5e5e92b0250f2aebaa32b7

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
