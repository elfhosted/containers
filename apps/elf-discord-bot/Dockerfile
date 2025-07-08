# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://$ZURG_GH_CREDS@github.com/jamcalli/elf-discord-bot.git /source

FROM node:23.6.0-alpine AS builder

WORKDIR /app

# Copy build essentials
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/src ./src
COPY --from=cloner /source/tsconfig.json ./

# Install dependencies
RUN npm ci

# Build
RUN npm run build

FROM node:23.6.0-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY --from=cloner /source/package*.json ./
RUN npm ci

# Create necessary directories and non-root user
RUN mkdir -p /app/data/db && \
    mkdir -p /app/data/log && \
    addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Copy build artifacts and migrations
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src
COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh && \
    chown -R nodejs:nodejs /app
# Switch to non-root user
USER nodejs

# Set production environment
ENV NODE_ENV=production

# Make volumes
VOLUME /app/data
EXPOSE 3000

CMD ["./docker-entrypoint.sh"]