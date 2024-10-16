ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:e76ead6a3355740808f715e2ed7a2047d46c733171b913f00ab119534b437f28

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
