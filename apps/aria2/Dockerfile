ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:503c6e796fa179fb55840b93f3ab7b4274327d116cede7d07a3895ccaf4715ae

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
