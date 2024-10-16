ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:7f79bf8242200fbf8a7c5a3858176f43bbf0c4eb0e2da287071445b8b52b0c01

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
