# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/arvida42/davdebrid.git /source

FROM node:22-slim

RUN mkdir -p /home/node/app && chown -R node:node /home/node/app \
  && mkdir -p /data && chown -R node:node /data

WORKDIR /home/node/app

COPY --chown=node:node --from=cloner /source/package*.json ./

USER node

RUN npm install

COPY --chown=node:node --from=cloner /source/src ./src

EXPOSE 4000

COPY ./apps/ubuntu/scripts/vpn.sh /scripts/vpn.sh
COPY ./apps/davdebrid/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]