ARG VERSION
FROM  thomseddon/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:de8a5005bc5d3ae169d3f54a190df394dee4d9ecbcab1f7be1f055905d4137c2 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]