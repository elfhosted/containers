# Kan (https://github.com/kanbn/kan) is AGPL-3.0, so this Dockerfile is public.
#
# We reuse upstream's released images rather than rebuilding the Next.js
# monorepo: the web image carries the standalone server (built on node:20-alpine,
# so its native modules are musl-compatible), and the migrate image carries the
# drizzle migrations plus drizzle-orm/pg to apply them.
ARG VERSION
FROM ghcr.io/kanbn/kan:${VERSION} AS upstream
FROM ghcr.io/kanbn/kan-migrate:${VERSION} AS migrate

# Keep only what the runtime migrator needs (drop drizzle-kit and esbuild)
FROM alpine:latest AS migrate-prune
COPY --from=migrate /db /db
RUN rm -rf /db/node_modules/drizzle-kit /db/node_modules/esbuild /db/node_modules/@esbuild \
      /db/node_modules/@drizzle-team /db/node_modules/@esbuild-kit /db/drizzle.config.ts \
      /db/package-lock.json

FROM ghcr.io/elfhosted/alpine:rolling@sha256:f6ba42afb0be46de3fec300aed6a542f892ad822c357f044eb6a96d9a36661c1

RUN apk add --no-cache nodejs tini ca-certificates

ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME=0.0.0.0 \
    NEXT_TELEMETRY_DISABLED=1

COPY --from=upstream --chown=568:568 /app /app
COPY --from=migrate-prune --chown=568:568 /db /db
COPY --chmod=755 apps/kan/entrypoint.sh /entrypoint.sh
COPY --chmod=644 apps/kan/migrate.mjs /db/migrate.mjs
COPY --chmod=644 apps/kan/bootstrap.mjs /app/bootstrap.mjs
COPY --chmod=644 apps/kan/pg-shared-pool.js /app/node_modules/pg/lib/elfhosted-shared-pool.js

# Share one pg.Pool per configuration instead of one per request (see the file)
RUN printf '\nrequire("./elfhosted-shared-pool.js")(module.exports)\n' >> /app/node_modules/pg/lib/index.js

# Read-only rootfs: bootstrap.mjs rewrites public/__ENV.js at every start (runtime
# NEXT_PUBLIC_* injection) and Next.js writes its cache under .next/cache. Both
# are pointed at /tmp.
RUN ln -sf /tmp/__ENV.js /app/apps/web/public/__ENV.js && \
    rm -rf /app/apps/web/.next/cache && \
    ln -s /tmp/next-cache /app/apps/web/.next/cache

WORKDIR /app
USER 568:568
EXPOSE 3000

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
