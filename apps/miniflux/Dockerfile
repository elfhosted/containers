ARG VERSION
FROM ghcr.io/miniflux/miniflux:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:05a4a21c5a2f0a133ba338fe802e0565bd2b9b0da7aac7a254df2e5833511900 
COPY --from=upstream /usr/bin/miniflux /usr/bin/miniflux

ENV LISTEN_ADDR 0.0.0.0:8080
CMD ["/usr/bin/miniflux"]
