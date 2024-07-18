# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/advplyr/audiobookshelf.git /source

### STAGE 0: Build client ###
FROM node:20-alpine AS build
WORKDIR /client
COPY --from=cloner /source/client /client
RUN npm ci && npm cache clean --force
RUN npm run generate

### STAGE 1: Build server ###
FROM ghcr.io/elfhosted/alpine:rolling@sha256:3d8693e2e68a277e14e96594381f8b8620c81ada3827babb842faeaae607693f

ENV NODE_ENV=production

RUN apk update && \
    apk add --no-cache --update \
    curl \
    tzdata \
    ffmpeg \
    make \
    python3 \
    g++ \
    tini

COPY --from=build /client/dist /client/dist
COPY --from=cloner /source/index.js package* /
COPY --from=cloner /source/server server

RUN npm ci --only=production

RUN apk del make python3 g++

EXPOSE 80

ENTRYPOINT ["tini", "--"]
CMD ["node", "index.js"]