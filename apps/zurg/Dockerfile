ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:3.17.6@sha256:d41be5718cd359aa4ad92c5281cfaf5d1396d35da930d52b8d33582bb26f9b55 

WORKDIR /config

# Needed for the plex-update script
RUN apk add --no-cache python3 libxml2-utils 

COPY --from=upstream /app/zurg /app/
COPY --from=upstream /app/config.yml /config/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]