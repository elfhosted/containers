# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b feature/seerrbridge-test https://github.com/jamcalli/pulsarr.git /source

FROM node:23.6.0-alpine AS builder

WORKDIR /app

# Set cache dir
ENV CACHE_DIR=/app/build-cache

# Copy build essentials
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/src ./src
COPY --from=cloner /source/vite.config.js ./
COPY --from=cloner /source/tsconfig.json ./
COPY --from=cloner /source/tailwind.config.ts ./
COPY --from=cloner /source/postcss.config.mjs ./

# Install dependencies
RUN npm ci

# Build
RUN npm run build

# Ensure cache dir
RUN mkdir -p ${CACHE_DIR}

FROM node:23.6.0-alpine

WORKDIR /app

# cache dir in final
ENV CACHE_DIR=/app/build-cache

# Copy package files and install dependencies
COPY --from=cloner /source/package*.json ./
RUN npm ci

# Create necessary directories
RUN mkdir -p /app/data/db && \
    mkdir -p /app/data/log && \
    mkdir -p ${CACHE_DIR}

# Copy build artifacts, config, and cache
COPY --from=builder /app/dist ./dist
COPY --from=builder ${CACHE_DIR} ${CACHE_DIR}
COPY --from=cloner /source/vite.config.js ./
COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

# Set production environment
ENV NODE_ENV=production

# Make volumes
VOLUME ${CACHE_DIR}
VOLUME /app/data
EXPOSE 3003

CMD ["./docker-entrypoint.sh"]