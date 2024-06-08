ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3d8693e2e68a277e14e96594381f8b8620c81ada3827babb842faeaae607693f

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
