ARG VERSION
FROM ghcr.io/autobrr/autobrr:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:487b892722a9e3c8e46eeddd890eb0ab039aa71c2339220164628094863bf5ad 

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