ARG VERSION
FROM ghcr.io/advplyr/audiobookshelf:${VERSION} as upstream

LABEL org.opencontainers.image.source = "https://github.com/advplyr/audiobookshelf"

FROM node:16-alpine

ENV NODE_ENV=production
ENV UID=568
ENV GID=568
ENV METADATA_PATH=/config/metadata
ENV CONFIG_PATH=/config/config
ENV PORT=8000
ENV npm_config_cache=/tmp

RUN apk update && \
    apk add --no-cache --update \
    curl \
    tzdata \
    ffmpeg && \
    addgroup -S seedy --gid 568 \
    && adduser -S seedy -G seedy --uid 568 \
    && \
    mkdir -p /config \
    && chown -R seedy:seedy /config \
    && chmod -R 775 /config


COPY --chown=$UID:$GID --from=upstream /usr/local/bin/tone /usr/local/bin/
COPY --chown=$UID:$GID --from=upstream /client /client
COPY --chown=$UID:$GID --from=upstream /server /server
COPY --chown=$UID:$GID --from=upstream /index.js /
COPY --chown=$UID:$GID --from=upstream /package* /

EXPOSE 8000
RUN npm ci --only=production

USER 568

# HEALTHCHECK \
#     --interval=30s \
#     --timeout=3s \
#     --start-period=10s \
#     CMD curl -f http://127.0.0.1/healthcheck || exit 1

CMD [ "npm","start" ]