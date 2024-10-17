ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:3.19.4@sha256:4293c1100c1dc1839feaac751f1066cbf8543701212e7abbc833bf8cb2ecd2b6 

WORKDIR /config

# Needed for the plex-update script
RUN apk add --no-cache python3 libxml2-utils 

COPY --from=upstream /app/zurg /app/
COPY --from=upstream /app/config.yml /config/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]