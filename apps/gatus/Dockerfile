ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:523b82a80cbc42de1b430e84afff4c09b377387d3d0fb2e43ba7317d49d84607 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
