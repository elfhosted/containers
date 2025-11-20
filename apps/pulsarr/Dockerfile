# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/jamcalli/pulsarr.git /source

FROM node:24.11.1-trixie AS builder

WORKDIR /app

# Accept TMDB API key as build argument (GitHub Actions converts to TMDBAPIKEY)
ARG TMDBAPIKEY

# Set cache dir
ENV CACHE_DIR=/app/build-cache

# Set TMDB API key as environment variable in camelCase format
ENV tmdbApiKey=${TMDBAPIKEY}

# Copy package files first (changes less often)
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/.npmrc ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=cache,target=/app/.npm \
    HUSKY=0 npm ci --prefer-offline --no-audit

# Copy build configuration files
COPY --from=cloner /source/vite.config.js /source/tsconfig.json /source/postcss.config.mjs ./

# Copy source code (changes most often)
COPY --from=cloner /source/src ./src

# Build with cache mounts
RUN --mount=type=cache,target=/app/node_modules/.vite \
    npm run build

# Prune dev dependencies to produce production node_modules for runtime image
RUN npm prune --omit=dev && mkdir -p ${CACHE_DIR}

FROM node:24.11.0-trixie

WORKDIR /app

# cache dir in final
ENV CACHE_DIR=/app/build-cache

# Copy package files (runtime typically does not need .npmrc)
COPY --from=cloner /source/package*.json ./
# Reuse production dependencies from the builder image
COPY --from=builder /app/node_modules ./node_modules

# Create necessary directories
RUN mkdir -p /app/data/db && \
    mkdir -p /app/data/log && \
    mkdir -p ${CACHE_DIR}

# Copy build artifacts
COPY --from=builder /app/dist ./dist
COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

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

CMD ["./docker-entrypoint.sh"]