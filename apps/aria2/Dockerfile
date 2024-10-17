ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:a56135e0488267f3b18bc4ada6c39b67e5c9657aeced224a67b173764c6ea80b

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
