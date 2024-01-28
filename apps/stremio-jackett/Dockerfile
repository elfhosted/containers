FROM ghcr.io/geek-cookbook/alpine-node:20@sha256:34e579ce8fd045ec28105d0ee720e6d4b8fd332ebeb8d4890784b8b991d51e29

ENV PORT 7001
RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /app

# Get latest dev
RUN git clone -b dev https://github.com/aymene69/stremio-jackett.git /tmp/source && \
    cp /tmp/source/${CHANNEL}/package*.json ./ && \
    npm install && \
    cp -rf /tmp/source/${CHANNEL}/* . && \
    rm -rf /tmp/source

# Get ElfHosted branding
RUN git clone https://github.com/geek-cookbook/stremio-jackett.git /tmp/elfhosted && \
    cp /tmp/elfhosted/src/routes.js src/ && \
    cp /tmp/elfhosted/src/index.html src/ && \
    cp /tmp/elfhosted/dist/index.html dist/ && \
    rm -rf /tmp/source


CMD [ "npm", "start" ]