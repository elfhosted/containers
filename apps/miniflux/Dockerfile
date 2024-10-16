ARG VERSION
FROM ghcr.io/miniflux/miniflux:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:7ee02f5751df44b1acc07afab7ec8fb07cfed722697ba1ecab2dd5ef0df963b6 
COPY --from=upstream /usr/bin/miniflux /usr/bin/miniflux

ENV LISTEN_ADDR 0.0.0.0:8080
CMD ["/usr/bin/miniflux"]
