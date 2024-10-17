ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c09000173c56e1ccf19e9586b01900636f0270369cf3e7722d84b0220dafd02

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
