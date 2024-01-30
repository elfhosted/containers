ARG VERSION

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:6b59b2060ffbb6af76654aae9f5185fbfdfb08b2532d0186f3b14e8ad26b7598

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
