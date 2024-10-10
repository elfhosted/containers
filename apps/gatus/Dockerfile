ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:6ab3d945f706242c59518d185e003203de2c59702c04eebfbde6a5119f8f114a 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
