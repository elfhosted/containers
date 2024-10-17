ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:f47f2ef8bd7ff63c8edbad27475aac7ed641cc9f3bb264bd2db2332cf19d2287

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
