ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:523b82a80cbc42de1b430e84afff4c09b377387d3d0fb2e43ba7317d49d84607 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]