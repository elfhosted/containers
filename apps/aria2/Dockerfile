ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:6ab3d945f706242c59518d185e003203de2c59702c04eebfbde6a5119f8f114a

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
