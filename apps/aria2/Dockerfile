ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:4293c1100c1dc1839feaac751f1066cbf8543701212e7abbc833bf8cb2ecd2b6

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
