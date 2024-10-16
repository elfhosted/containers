ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:97d4184c307315f0e099d09921eccc1c240ad362f835dd0a44d789927116bec0

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
