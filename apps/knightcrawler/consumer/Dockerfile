# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/geek-cookbook/torrentio.elfhosted.com.git /source

FROM node:lts-buster-slim as builder
ENV CLONE_PATH=/source/src/node/consumer

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=cloner $CLONE_PATH/package*.json ./
RUN npm install
COPY --from=cloner $CLONE_PATH/. .
RUN npm run build

# --- Runtime Stage ---
FROM node:lts-buster-slim

WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app ./
RUN npm prune --omit=dev

EXPOSE 7001

ENTRYPOINT [ "node", "dist/index.cjs" ]




