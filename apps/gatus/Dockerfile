ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:e92c2494b7c92e6a522a791440642fb25ce160c00906d7ac82efb8e5a5b20044 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
