FROM node:latest

ARG CHANNEL
ARG VERSION

ENV PORT 7001
RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/aymene69/stremio-jackett.git /tmp/source && \
    cp /tmp/source/${CHANNEL}/package*.json ./ && \
    npm install && \
    cp -rf /tmp/source/${CHANNEL}/* . && \
    rm -rf /tmp/source

CMD [ "npm", "start" ]