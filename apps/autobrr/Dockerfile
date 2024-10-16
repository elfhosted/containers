ARG VERSION
FROM ghcr.io/autobrr/autobrr:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:4293c1100c1dc1839feaac751f1066cbf8543701212e7abbc833bf8cb2ecd2b6 

LABEL org.opencontainers.image.source = "https://github.com/autobrr/autobrr"

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

WORKDIR /app

VOLUME /config

COPY --from=upstream /usr/local/bin/autobrr /usr/local/bin/
COPY --from=upstream /usr/local/bin/autobrrctl /usr/local/bin/

COPY ./apps/autobrr/regbrr.sh /

EXPOSE 7474

ENTRYPOINT ["/usr/local/bin/autobrr", "--config", "/config"]