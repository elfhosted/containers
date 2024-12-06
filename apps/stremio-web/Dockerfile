FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Stremio/stremio-web.git /source

# Copied from https://github.com/Stremio/stremio-web/blob/development/Dockerfile and modified for cloner source
# Stremio Node 14.x# the node version for running Stremio Web
FROM node:22-alpine AS base

# Meta
LABEL Description="Stremio Web" Vendor="Smart Code OOD" Version="1.0.0"

RUN mkdir -p /var/www/stremio-web
WORKDIR /var/www/stremio-web

# Install app dependencies
FROM base AS prebuild

RUN apk update && apk upgrade && \
    apk add --no-cache git
WORKDIR /var/www/stremio-web
COPY --from=cloner /source/. .
RUN npm install
RUN npm run build

# Bundle app source
FROM base AS final

WORKDIR /var/www/stremio-web
COPY --from=cloner /source/. .
COPY --from=prebuild /var/www/stremio-web/node_modules ./node_modules
COPY --from=prebuild /var/www/stremio-web/build ./build

EXPOSE 8080
CMD ["node", "http_server.js"]
