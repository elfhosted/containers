# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://bitbucket.org/shluflix-stremio/shluflix.git /source

FROM ghcr.io/elfhosted/alpine-node:20@sha256:6012d04af741b80f2c2d21fe6088a2c096383fdb4269567f837e500af888dd69
WORKDIR /app
COPY --from=cloner /source .
COPY apps/shluflix/branding/landingTemplate.js .
COPY apps/shluflix/branding/addon.js .
RUN npm install
CMD ["npm", "start"]
