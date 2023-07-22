ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:e92c2494b7c92e6a522a791440642fb25ce160c00906d7ac82efb8e5a5b20044 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]