# Get the upstream code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/ReemX/stremio-comments-addon.git  /source

FROM denoland/deno:latest as base

WORKDIR /app

COPY --from=cloner /source/. ./

RUN deno install

CMD ["deno", "task", "dev"]
