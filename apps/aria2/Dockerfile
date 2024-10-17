ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:d143aa2ae054d1061cb6abc8a820506c90330e51fcc95dc7b7f4d2462b61ed3a

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
