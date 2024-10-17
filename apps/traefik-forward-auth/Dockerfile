ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]