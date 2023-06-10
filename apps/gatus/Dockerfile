ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:761ae0cc8203517a5ce76527eea053bcf12689f59c0a4cf334cb380f64c60c60

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]