ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:627245a90cbfe877d2beddadcc00e0af149b26ef38bd2956a35ee999e2d1c556

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
