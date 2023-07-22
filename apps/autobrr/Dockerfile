ARG VERSION
FROM ghcr.io/autobrr/autobrr:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:a03913e04428c49195fa0b4c9a6e7cfad889692b4839937b387b0a2a06f25733 

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