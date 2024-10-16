ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:05a4a21c5a2f0a133ba338fe802e0565bd2b9b0da7aac7a254df2e5833511900 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]