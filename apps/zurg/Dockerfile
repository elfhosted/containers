ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:6b59b2060ffbb6af76654aae9f5185fbfdfb08b2532d0186f3b14e8ad26b7598 

WORKDIR /config

# Needed for the plex-update script
RUN apk add --no-cache python3

COPY --from=upstream /app/zurg /app/
COPY --from=upstream /app/config.yml /config/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]