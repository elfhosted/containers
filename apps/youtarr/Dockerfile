# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $(echo $VERSION | cut -d'-' -f1) https://github.com/DialmasterOrg/Youtarr.git /source

# ---- Base Node ----
FROM node:20-slim AS base
WORKDIR /app

# ---- Dependencies ----
FROM base AS dependencies
COPY --from=cloner /source/package*.json ./
# Skip prepare script (husky) for production dependencies
RUN npm ci --only=production --ignore-scripts

# ---- Build ----
FROM base AS build
COPY --from=cloner /source/package*.json ./
RUN npm ci

# Copy server code and built React app
COPY --from=cloner /source/server/ ./server/
# COPY --from=cloner /source/client/build/ ./client/build/
COPY --from=cloner /source/migrations/ ./migrations/

# ---- Client build ----
FROM base AS client-build
WORKDIR /app/client

# install client deps
COPY --from=cloner /source/client/package*.json ./
RUN npm ci

# build client
COPY --from=cloner /source/client ./
RUN npm run build

# ---- Release ----
FROM node:20-slim AS release
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    unzip \
    python3-minimal \
    && rm -rf /var/lib/apt/lists/*

# Download the latest yt-dlp release directly from GitHub
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod +x /usr/local/bin/yt-dlp

# Install Deno
ENV DENO_INSTALL="/usr/local"
RUN curl -fsSL https://deno.land/install.sh | sh

# Copy production node_modules
COPY --from=dependencies /app/node_modules ./node_modules

# Copy application files
COPY --from=build /app/server ./server
COPY --from=client-build /app/client/build ./client/build
COPY --from=build /app/migrations ./migrations

# Copy config.example.json to server directory (guaranteed to exist and accessible)
COPY --from=cloner /source/config/config.example.json /app/server/config.example.json

# Copy the new simplified entrypoint script
COPY --from=cloner /source/scripts/docker-entrypoint-simple.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port for the application
EXPOSE 3011

# Health check
COPY --from=cloner /source /upstream-source
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl --fail --silent --show-error --output /dev/null http://localhost:3011/api/health || exit 1

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]