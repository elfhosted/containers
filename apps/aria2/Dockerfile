ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3b4cab09b3afd338e4947e435725741ada7791e134547dffb4419eee2157bfe7

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
