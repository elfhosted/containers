ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:abe1c6726d152183da7903907260981392b0feb43bb8238e174a4dbaddcd2f53

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
