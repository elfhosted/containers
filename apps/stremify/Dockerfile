# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/stremify/stremify /source

FROM node:20-slim

RUN mkdir -p /home/node/app && chown -R node:node /home/node/app \
  && mkdir -p /data && chown -R node:node /data

WORKDIR /home/node/app

COPY --chown=node:node --from=cloner source/package*.json ./

USER node

RUN npm install

COPY --chown=node:node --from=cloner source/. .

EXPOSE 3000

CMD [ "npm", "run", "dev" ]