ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:3.19.1@sha256:afee25e18dd1ab956742f0c9a685c245dd9384348d2e00b0f54a3c69d272468f 

WORKDIR /config

# Needed for the plex-update script
RUN apk add --no-cache python3 libxml2-utils 

COPY --from=upstream /app/zurg /app/
COPY --from=upstream /app/config.yml /config/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]