# Get the upstream code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/schlagmichdoch/PairDrop.git  /source

FROM alpine:latest

WORKDIR /home/node/app

COPY --from=cloner /source/package*.json ./

RUN apk add --no-cache nodejs npm
RUN NODE_ENV="production" npm ci --omit=dev

# Directories and files excluded via .dockerignore
COPY --from=cloner /source/. .

# environment settings
ENV NODE_ENV="production"

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1

ENTRYPOINT ["npm", "start"]