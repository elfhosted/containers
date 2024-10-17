ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:c104de5b07c8ee57c9d02d21c06929e3f006f689d5c601628dbec8528d844065

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
