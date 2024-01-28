FROM ghcr.io/geek-cookbook/alpine-node:20@sha256:34e579ce8fd045ec28105d0ee720e6d4b8fd332ebeb8d4890784b8b991d51e29

ENV PORT 7001
RUN apk update && apk upgrade && \
    apk add --no-cache git patch

WORKDIR /app

# Get latest main (once dev is fixed we'll get it instead)
RUN git clone -b main https://github.com/aymene69/stremio-jackett.git /tmp/source && \
    cp /tmp/source/package*.json ./ && \
    npm install && \
    cp -rf /tmp/source/* . && \
    rm -rf /tmp/source


# ElfHosted branding
RUN git clone https://github.com/geek-cookbook/stremio-jackett.git /tmp/elfhosted && \
    cp /tmp/elfhosted/src/routes.js src/ && \
    cp /tmp/elfhosted/src/index.html src/ && \
    cp /tmp/elfhosted/dist/index.html dist/ && \
    rm -rf /tmp/source

# Patch RD timeout bug
RUN wget https://github.com/aymene69/stremio-jackett/commit/80109635d1a9cb1596b60b529355986a7d5e50ed.patch && \
    patch -p1 < 80109635d1a9cb1596b60b529355986a7d5e50ed.patch


CMD [ "npm", "start" ]