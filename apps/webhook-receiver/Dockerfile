
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

FROM        ghcr.io/geek-cookbook/alpine:rolling@sha256:b612a392da0d0934ce4136552afadf0c33f00a0306dfa53758b5724f26212cb2 
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN         apk add --update curl jq yq gettext git openssh-client github-cli
WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
USER        568