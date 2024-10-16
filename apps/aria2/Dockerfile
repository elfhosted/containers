ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:31de07bc212a284a77c1f1e13ac7065cf8b7e679357f28e6ba7fa88244ec88df

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
