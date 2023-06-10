ARG VERSION
FROM  thomseddon/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:b612a392da0d0934ce4136552afadf0c33f00a0306dfa53758b5724f26212cb2 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]