ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:afb00cc50357341fb591a9940889c31e330d9a2e7f4a7d7cb77ef24f00cc423b 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
