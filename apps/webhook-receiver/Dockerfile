
# Dockerfile for https://github.com/adnanh/webhook
FROM        golang:alpine AS build
ARG VERSION
WORKDIR     /go/src/github.com/adnanh/webhook
# ENV         WEBHOOK_VERSION 2.8.1
RUN         apk add --update -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -o /usr/local/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf /go

FROM        ghcr.io/geek-cookbook/alpine:rolling@sha256:4dfe788cfba535bfab66a317f10e49c5e0e54d607f711bf2dd31937a6efccdca 
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN         apk add --update curl jq yq gettext git openssh-client github-cli
WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
USER        568