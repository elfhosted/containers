FROM ghcr.io/elfhosted/alpine:rolling@sha256:d79a0a751437bd06cdc029ad01b972ccb057de65ca09da1e68c576ee4467ec44
ARG VERSION
RUN apk update && \
	apk add --no-cache --update bash && \
	mkdir -p /aria2-ng && \
	mkdir -p /usr/local/nginx/html && \
	apk add --no-cache wget && \
    wget https://github.com/mayswind/AriaNg/releases/download/${VERSION}/AriaNg-${VERSION}.zip -O /aria2-ng/archive.zip && \
    cd /aria2-ng && \
    unzip archive.zip && \
    rm archive.zip && \
    apk del wget && \
    apk add --update nginx && \
    rm -rf /var/cache/apk/*

ADD apps/ariang/files/nginx.conf /etc/nginx/nginx.conf
ADD apps/ariang/entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]