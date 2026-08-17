# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://bitbucket.org/shluflix-stremio/shluflix.git /source

FROM ghcr.io/elfhosted/alpine-node:20@sha256:63cd08a437bf895ce064b908b86e1c420f46dd4d4fbb648482fb957fb807a922
WORKDIR /app
COPY --from=cloner /source .
COPY apps/shluflix/branding/landingTemplate.js .
COPY apps/shluflix/branding/addon.js .
RUN npm install
CMD ["npm", "start"]
