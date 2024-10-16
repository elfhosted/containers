ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:3.19.1@sha256:dfb0a18161228f317ed4c96630d70d7855d546a522c0017cbe76b907dabae8ec 

WORKDIR /config

# Needed for the plex-update script
RUN apk add --no-cache python3 libxml2-utils 

COPY --from=upstream /app/zurg /app/
COPY --from=upstream /app/config.yml /config/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]