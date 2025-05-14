ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c3dbccc25e349861a983e12ab7c2b2f14a6365dacbe2c500a819dd103164af6

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
