ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:2fbe8a2a4806efd76d40a31891112fac02b061b6ac98a6d4377c88c89f2577ce

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
