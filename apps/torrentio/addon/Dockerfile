FROM node:16-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /home/node/app

RUN git clone https://github.com/Pukabyte/torrentio-scraper-sh.git /tmp/source && \
    cp /tmp/source/package*.json ./ && \
    npm ci --only-production && \
    cp /tmp/source/addon . && \
    rm -rf /tmp/source

CMD [ "node", "--insecure-http-parser", "index.js" ]