ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]