ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:7ee02f5751df44b1acc07afab7ec8fb07cfed722697ba1ecab2dd5ef0df963b6

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
