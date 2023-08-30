ARG VERSION
FROM ghcr.io/miniflux/miniflux:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 
COPY --from=upstream /usr/bin/miniflux /usr/bin/miniflux

ENV LISTEN_ADDR 0.0.0.0:8080
CMD ["/usr/bin/miniflux"]
