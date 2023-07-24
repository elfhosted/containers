ARG VERSION
FROM twinproduction/gatus:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:90392adc7a86641ddeebd29bcbbfd21b625e84cf7446a33f1628db5fff06918c 

COPY --from=upstream /gatus /
COPY --from=upstream /config/config.yaml ./config/config.yaml

ENV PORT=8080
EXPOSE ${PORT}

ENTRYPOINT ["/gatus"]
