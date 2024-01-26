FROM node:16-alpine

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /home/node/app

RUN git clone https://github.com/geek-cookbook/torrentio.elfhosted.com.git /tmp/source && \
    cp /tmp/source/${CHANNEL}/package*.json ./ && \
    npm ci --only-production && \
    cp -rf /tmp/source/${CHANNEL}/* . && \
    rm -rf /tmp/source

ENTRYPOINT [ "./entrypoint.sh" ]