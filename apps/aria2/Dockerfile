ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:0782c9e41d6e1efe014e1081a12f9f25665aa9b18372de4bd9bb848ace53cceb

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
