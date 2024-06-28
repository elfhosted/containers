# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# RUN git clone -b $VERSION  https://github.com/elfhosted/knightcrawler.git /source
RUN git clone  https://github.com/elfhosted/knightcrawler.git /source


# --- Build Stage ---
FROM node:lts-alpine AS builder

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /app

COPY --from=cloner /source/src/addon/package*.json ./

RUN npm install
COPY --from=cloner /source/src/addon/. .

# ElfHosted branding
COPY apps/knightcrawler/branding/manifest.js ./src/lib/manifest.js
COPY apps/knightcrawler/branding/landingTemplate.js ./src/lib/landingTemplate.js

RUN npm run build

# --- Runtime Stage ---
FROM node:lts-alpine

# Install pm2
RUN npm install pm2 -g

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app ./
RUN npm prune --omit=dev

# CIS-DI-0001
RUN addgroup -S addon && adduser -S -G addon addon
USER addon

EXPOSE 7000

ENTRYPOINT [ "pm2-runtime", "start", "ecosystem.config.cjs"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD pm2 ping || exit 1