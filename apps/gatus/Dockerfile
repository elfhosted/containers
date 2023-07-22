ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:a03913e04428c49195fa0b4c9a6e7cfad889692b4839937b387b0a2a06f25733 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
