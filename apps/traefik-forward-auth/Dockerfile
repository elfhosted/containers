ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:e76ead6a3355740808f715e2ed7a2047d46c733171b913f00ab119534b437f28 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]