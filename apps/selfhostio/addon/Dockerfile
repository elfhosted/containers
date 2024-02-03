# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $CHANNEL https://github.com/geek-cookbook/torrentio.elfhosted.com.git /source

# Build per the original dockerfile
FROM node:lts-alpine AS builder
ENV CLONE_PATH=/source/src/node/addon

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /app

COPY --from=cloner $CLONE_PATH/package*.json .
RUN npm install
COPY --from=cloner $CLONE_PATH/. .
RUN npm run build

# --- Runtime Stage ---
FROM node:lts-alpine

# Install pm2
RUN npm install pm2 -g

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/ ./
RUN npm prune --omit=dev

EXPOSE 7000

ENTRYPOINT [ "pm2-runtime", "start", "ecosystem.config.cjs"]l