ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:2fae8fc2d24a94a4762e061b2f72e0ef3d33cc2525d7ad479d25cc76de67b32b

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
