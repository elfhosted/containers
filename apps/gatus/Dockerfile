ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:e76ead6a3355740808f715e2ed7a2047d46c733171b913f00ab119534b437f28 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
