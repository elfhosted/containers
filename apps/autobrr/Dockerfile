ARG VERSION
FROM ghcr.io/autobrr/autobrr:v${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3901b78e8dac885868634a530283571e15d955b70d4a4bff649c25fb6053f8d1 

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