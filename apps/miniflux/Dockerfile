ARG VERSION
FROM ghcr.io/miniflux/miniflux:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856 
COPY --from=upstream /usr/bin/miniflux /usr/bin/miniflux

ENV LISTEN_ADDR 0.0.0.0:8080
CMD ["/usr/bin/miniflux"]
