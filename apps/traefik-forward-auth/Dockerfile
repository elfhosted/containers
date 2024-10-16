ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:3901b78e8dac885868634a530283571e15d955b70d4a4bff649c25fb6053f8d1 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]