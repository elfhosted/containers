# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/xtremexq/StremioSubMaker.git /source

# Use Node.js LTS version
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies first (for better caching)
COPY --from=cloner /source/package*.json ./
RUN npm ci --only=production

# Copy application code
COPY --from=cloner /source/. .

# Create cache directories and keys directory for encryption key persistence
RUN mkdir -p .cache/translations \
    .cache/translations_bypass \
    .cache/translations_partial \
    .cache/sync_cache \
    data \
    logs \
    keys

# Set permissions (ensure node user owns all directories including keys)
RUN chown -R node:node /app

# Use non-root user
USER node

# Expose port (default 7001)
EXPOSE 7001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:7001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["npm", "start"]