# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/jamcalli/pulsarr.git /source

FROM node:23.6.0-alpine AS builder

WORKDIR /app

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

# Ensure cache directory exists for build
RUN mkdir -p node_modules/.cache/@fastify/vite

FROM node:23.6.0-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY --from=cloner /source/package*.json ./
RUN npm ci

# Create necessary directories
RUN mkdir -p /app/data/db && \
    mkdir -p /app/data/log && \
    mkdir -p node_modules/.cache/@fastify/vite

# Copy build artifacts, config, and cache
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.cache/@fastify/vite/vite.config.dist.json ./node_modules/.cache/@fastify/vite/
COPY --from=cloner /source/vite.config.js ./
COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

# Set production environment
ENV NODE_ENV=production

VOLUME /app/data
EXPOSE 3003

# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd --uid 568 --gid 568 --shell /bin/bash $user && \
    chown $user /app -R
USER 568

CMD ["./docker-entrypoint.sh"]