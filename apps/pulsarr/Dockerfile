# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b ${VERSION} https://github.com/jamcalli/pulsarr.git /source

FROM oven/bun:1.3.6-alpine AS base
WORKDIR /app

# Install production dependencies in a temp directory (cached independently)
FROM base AS install
COPY --from=cloner /source/package.json /source/bun.lock ./
COPY --from=cloner /source/packages ./packages
RUN mkdir -p /temp/prod && \
    cp package.json bun.lock /temp/prod/ && \
    cp -r packages /temp/prod/packages && \
    cd /temp/prod && \
    bun install --frozen-lockfile --production --ignore-scripts

# Build stage: full install + compile
FROM base AS builder
ARG TMDBAPIKEY
ENV tmdbApiKey=${TMDBAPIKEY}

COPY --from=cloner /source/package.json /source/bun.lock ./
COPY --from=cloner /source/packages ./packages

RUN --mount=type=cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

COPY --from=cloner /source/vite.config.js /source/tsconfig.json /source/postcss.config.mjs ./
COPY --from=cloner /source/src ./src

RUN --mount=type=cache,target=/app/node_modules/.vite \
    bun run build

# Final runtime image
FROM base

# wget for healthcheck
RUN apk add --no-cache wget

ENV CACHE_DIR=/app/build-cache

# Copy package files
COPY --from=cloner /source/package.json /source/bun.lock ./
COPY --from=cloner /source/packages ./packages
# Production-only dependencies from the install stage
COPY --from=install /temp/prod/node_modules ./node_modules

# Create necessary directories
RUN mkdir -p /app/data/db && \
    mkdir -p /app/data/log && \
    mkdir -p ${CACHE_DIR}

# Copy build artifacts
COPY --from=builder /app/dist ./dist
COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh
COPY --from=cloner /source/docker-healthcheck.sh ./
RUN chmod +x docker-healthcheck.sh

# Copy license and documentation files for compliance
COPY --from=cloner /source/LICENSE* ./
COPY --from=cloner /source/README.md ./

# Pass TMDB API key to runtime (GitHub Actions converts to TMDBAPIKEY)
ARG TMDBAPIKEY

# Set production environment
ENV NODE_ENV=production
ENV tmdbApiKey=${TMDBAPIKEY}

# Make volumes
VOLUME ["/app/build-cache"]
VOLUME ["/app/data"]
EXPOSE 3003

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ./docker-healthcheck.sh

CMD ["./docker-entrypoint.sh"]