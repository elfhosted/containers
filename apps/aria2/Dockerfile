ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:adba843c93f612e67aa9745d8cc7a9ed17bfd11501d778c3cd115267fc59d4d1

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
