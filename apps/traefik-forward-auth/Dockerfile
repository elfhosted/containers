ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:a03913e04428c49195fa0b4c9a6e7cfad889692b4839937b387b0a2a06f25733 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]