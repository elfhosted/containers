ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:c104de5b07c8ee57c9d02d21c06929e3f006f689d5c601628dbec8528d844065 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
