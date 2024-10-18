# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://bitbucket.org/shluflix-stremio/shluflix.git /source

FROM ghcr.io/elfhosted/alpine-node:20@sha256:8527e12abf562e0b2e1cdb74d4186e9745c14b72d0c897ac3b6de4db3a49cb61
WORKDIR /app
COPY --from=cloner /source .
COPY apps/shluflix/branding/landingTemplate.js .
COPY apps/shluflix/branding/addon.js .
RUN npm install
CMD ["npm", "start"]
