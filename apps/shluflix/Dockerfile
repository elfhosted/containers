# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://bitbucket.org/shluflix-stremio/shluflix.git /source

FROM ghcr.io/geek-cookbook/alpine-node:20@sha256:8ab170d0ecfd6d044e0e1984e1923d906a7320c855bbc9629d40f0f059bbad9b
WORKDIR /app
COPY --from=cloner /source .
COPY apps/shluflix/branding/landingTemplate.js .
RUN npm install
CMD ["npm", "start"]
