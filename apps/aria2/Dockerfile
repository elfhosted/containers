ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:6a02d1eae6b2c3b5d76befe1009944c36156fdf536f46ef57c47e2259b81ab1a

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
