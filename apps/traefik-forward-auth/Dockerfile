ARG VERSION
FROM  thomseddon/traefik-forward-auth:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:761ae0cc8203517a5ce76527eea053bcf12689f59c0a4cf334cb380f64c60c60
COPY --from=upstream /traefik-forward-auth /traefik-forward-auth
EXPOSE 4181
ENTRYPOINT ["/traefik-forward-auth"]