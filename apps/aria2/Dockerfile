ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:ba5334417d0d3b70c6a3314795a7780e7c51fe7e1afe16b5359e3c2902ac5895

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
