ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:d79a0a751437bd06cdc029ad01b972ccb057de65ca09da1e68c576ee4467ec44

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
