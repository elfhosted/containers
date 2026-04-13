# Wrap upstream image, override entrypoint to bypass supervisord/postgres/redis
# (we run postgres and redis as Kubernetes sidecars instead)
ARG VERSION
FROM ghcr.io/kikootwo/readmeabook:v${VERSION} as upstream

FROM upstream

USER root

# Create elfie user
RUN groupadd -g 568 elfie 2>/dev/null || true && \
    useradd -d /home/elfie --create-home --uid 568 --gid 568 --shell /bin/bash elfie 2>/dev/null || true

# Ensure app directories are owned by elfie
RUN chown -R 568:568 /app /app/config /app/cache /app/.next/cache 2>/dev/null || true && \
    mkdir -p /config && chown 568:568 /config

USER 568

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3030

EXPOSE 3030

# Bypass supervisord — just run the node app directly
# Prisma migrations are handled by the app on startup
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
