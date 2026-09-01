ARG VERSION
FROM ghcr.io/debridmediamanager/zurg-public:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:3.19.1@sha256:dfb0a18161228f317ed4c96630d70d7855d546a522c0017cbe76b907dabae8ec 

WORKDIR /config

# Runtime deps, matched to zurg-rc so the two images are interchangeable:
#   python3 + libxml2-utils  plex_update.sh / cli_debrid_update.sh
#   ffmpeg (ffprobe)         media_info_* directory filters (audiobooks)
#   curl                     WARP readiness wait in the entrypoint
#   socat                    decypharr-replacement stub in the entrypoint
RUN apk add --no-cache python3 libxml2-utils ffmpeg curl socat

# zurg-public ships only the binary -- no config.yml. The chart seeds
# /config/config.yml from the zurg-config ConfigMap, so nothing needs one here.
COPY --from=upstream /app/zurg /app/
COPY ./apps/zurg/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
