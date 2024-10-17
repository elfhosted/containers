FROM ghcr.io/elfhosted/alpine:rolling@sha256:ba5334417d0d3b70c6a3314795a7780e7c51fe7e1afe16b5359e3c2902ac5895
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