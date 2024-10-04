# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://bitbucket.org/shluflix-stremio/shluflix.git /source

FROM ghcr.io/elfhosted/alpine-node:20@sha256:576b2515ddc5e16fcd9c0338a53c7986f09877388a8f4f8e4a40d96a01c7d6d6
WORKDIR /app
COPY --from=cloner /source .
COPY apps/shluflix/branding/landingTemplate.js .
COPY apps/shluflix/branding/addon.js .
RUN npm install
CMD ["npm", "start"]
