ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:dc79fd559ca924e82f27cfc91313312a9b4b5d63a030670c8096898c29ac7d03

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
