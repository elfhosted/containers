ARG VERSION
FROM mesosphere/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:22c9c87f4e72199aeb63d30175dfed98d97e03797775dd6f9167adf0da3326ed 
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]