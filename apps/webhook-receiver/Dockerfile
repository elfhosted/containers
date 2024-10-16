
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

FROM        ghcr.io/elfhosted/alpine:rolling@sha256:4293c1100c1dc1839feaac751f1066cbf8543701212e7abbc833bf8cb2ecd2b6 
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN         apk add --update curl jq yq gettext git openssh-client github-cli

# Add kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
   	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
	rm kubectl

WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
USER        568