# TREK: a collaborative trip planner.
#
# This Dockerfile is PUBLIC (unlike most ElfHosted build configs) because TREK
# is licensed AGPL-3.0, and the build recipe for the image we run is part of
# the corresponding source we make available.
#
# TREK is built UNMODIFIED from the official upstream release tag, with no
# source patches. TREK's TRADEMARKS.md only permits using the TREK name for an
# executable built from an official release whose modifications are limited to
# switching existing features on/off, translations and minor bug fixes, so
# everything ElfHosted-specific here is packaging (user, paths, entrypoint) and
# runtime configuration (env vars), never code. Do not add patches to this
# image; if one ever looks necessary, it has to go upstream instead.
#
# The build stages mirror upstream's own Dockerfile at the same tag. The
# runtime stage differs only in how the process is started: upstream's CMD runs
# as root to chown the data dirs and then drops to `node` via gosu, which cannot
# work under runAsNonRoot + readOnlyRootFilesystem. Here the image runs directly
# as elfie (568) and all state lives under /config.

FROM public.ecr.aws/docker/library/alpine:3.22 AS cloner
ARG VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache git
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/liketrek/TREK.git /source


# ── shared workspace ─────────────────────────────────────────────────────────
FROM public.ecr.aws/docker/library/node:24-alpine AS shared-builder
WORKDIR /app
COPY --from=cloner /source/package.json /source/package-lock.json ./
COPY --from=cloner /source/shared/package.json ./shared/
RUN npm ci --workspace=shared
COPY --from=cloner /source/shared/ ./shared/
RUN npm run build --workspace=shared


# ── client (SPA) ─────────────────────────────────────────────────────────────
FROM public.ecr.aws/docker/library/node:24-alpine AS client-builder
WORKDIR /app
COPY --from=cloner /source/package.json /source/package-lock.json ./
COPY --from=cloner /source/shared/package.json ./shared/
COPY --from=cloner /source/client/package.json ./client/
# TREK v4.3.0 runs client/scripts/patch-maplibre.mjs from the client
# postinstall hook, so copy that script before npm ci. The full client tree is
# still copied only after shared/dist is available, mirroring upstream.
COPY --from=cloner /source/client/scripts/patch-maplibre.mjs ./client/scripts/
RUN npm ci --workspace=client
COPY --from=shared-builder /app/shared/dist ./shared/dist
COPY --from=cloner /source/client/ ./client/
RUN npm run build --workspace=client


# ── server ───────────────────────────────────────────────────────────────────
# --ignore-scripts skips native builds (better-sqlite3); those happen in the
# runtime stage against its glibc, exactly as upstream does.
FROM public.ecr.aws/docker/library/node:24-alpine AS server-builder
WORKDIR /app
COPY --from=cloner /source/package.json /source/package-lock.json ./
COPY --from=cloner /source/shared/package.json ./shared/
COPY --from=cloner /source/server/package.json ./server/
RUN npm ci --workspace=server --ignore-scripts
COPY --from=shared-builder /app/shared/dist ./shared/dist
COPY --from=cloner /source/server/ ./server/
RUN npm run build --workspace=server


# ── runtime ──────────────────────────────────────────────────────────────────
FROM public.ecr.aws/docker/library/node:24-trixie-slim
ARG VERSION
ARG APP_REVISION

LABEL org.opencontainers.image.title="TREK" \
      org.opencontainers.image.description="TREK: a collaborative trip planner, built unmodified from the official release." \
      org.opencontainers.image.source="https://github.com/liketrek/TREK" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$APP_REVISION \
      org.opencontainers.image.licenses="AGPL-3.0"

WORKDIR /app

COPY --from=cloner /source/package.json /source/package-lock.json ./
COPY --from=cloner /source/shared/package.json ./shared/
COPY --from=cloner /source/server/package.json ./server/

# Same package set as upstream: python3 + build-essential only exist to compile
# better-sqlite3 and are purged in the same layer; libkitinerary-bin provides
# the booking-confirmation extractor, symlinked to a fixed path. npm/npx are
# removed afterwards, as upstream does.
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata dumb-init wget ca-certificates python3 build-essential \
      libkitinerary-bin && \
    npm ci --workspace=server --omit=dev && \
    ln -sf "$(find /usr/lib -name kitinerary-extractor -type f | head -1)" /usr/local/bin/kitinerary-extractor && \
    test -x /usr/local/bin/kitinerary-extractor && \
    apt-get purge -y python3 build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /root/.npm /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx && \
    groupadd -g 568 elfie && \
    useradd -d /config --no-create-home -u 568 -g 568 -s /usr/sbin/nologin elfie

# Every COPY below matches one in upstream's runtime stage; each is read from
# disk at runtime:
#   server/assets       airports.json + atlas geojson (flight search, Atlas map)
#   wiki                in-app /help pages (otherwise fetched from GitHub)
#   server/tsconfig.json  tsconfig-paths/register resolves MCP SDK paths from it
#   migrate-encryption.ts on-demand key rotation, run via tsx from source
#   reset-admin.js      admin recovery for locked-out installs
# The image tree stays root-owned and read-only to elfie; nothing under /app is
# written at runtime except through the data/uploads symlinks into /config.
COPY --from=server-builder /app/server/dist ./server/dist
COPY --from=server-builder /app/server/assets ./server/assets
COPY --from=cloner /source/wiki ./wiki
COPY --from=cloner /source/server/tsconfig.json ./server/
COPY --from=cloner /source/server/scripts/migrate-encryption.ts ./server/scripts/migrate-encryption.ts
COPY --from=cloner /source/server/reset-admin.js ./server/reset-admin.js
COPY --from=shared-builder /app/shared/dist ./shared/dist
COPY --from=client-builder /app/client/dist ./server/public
COPY --from=client-builder /app/client/public/fonts ./server/public/fonts

# TREK resolves its data and uploads roots relative to its own install
# (server/data, server/uploads; not env-configurable), and upstream's image
# links those to /app/data and /app/uploads. The same two links are kept and
# the /app ones are pointed one hop further, into /config, so a single volume
# holds the SQLite DB, the auto-generated .encryption_key and .jwt_secret,
# logs, backups, plugins and every uploaded file.
RUN ln -s /config/data /app/data && \
    ln -s /config/uploads /app/uploads && \
    ln -s /app/data /app/server/data && \
    ln -s /app/uploads /app/server/uploads && \
    mkdir -p /config && \
    chown 568:568 /config

COPY apps/trek/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    chmod 0755 /usr/local/bin/entrypoint.sh

ENV NODE_ENV=production \
    NODE_USE_ENV_PROXY=1 \
    PORT=3000 \
    APP_VERSION=${VERSION} \
    HOME=/tmp \
    XDG_CACHE_HOME=/tmp/kf6-cache \
    QT_QPA_PLATFORM=offscreen \
    KITINERARY_EXTRACTOR_PATH=/usr/local/bin/kitinerary-extractor

USER 568:568

EXPOSE 3000

# Upstream's healthcheck, for plain `docker run`; Kubernetes ignores it and
# probes /api/health itself.
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

# Stay at /app so upstream's documented recovery command
# (`docker exec ... node server/reset-admin.js`) resolves; the entrypoint cd's
# into /app/server before starting the server, as upstream's CMD does.
WORKDIR /app

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["node", "--require", "tsconfig-paths/register", "dist/index.js"]
