# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/mikmc55/epgtv.git /source

FROM node:18.16.0-alpine as base

WORKDIR /app

COPY --from=cloner /source/package*.json ./

RUN npm install

COPY --from=cloner /source .

# ElfHosted branding
COPY apps/youriptv/branding/* .

# Copy tweaked addon.js (20s timeout, branding
COPY apps/youriptv/addon.js .

ENV NODE_ENV production

EXPOSE 3649

CMD [ "node", "index.js" ]