FROM ghcr.io/elfhosted/alpine:rolling@sha256:3901b78e8dac885868634a530283571e15d955b70d4a4bff649c25fb6053f8d1 

# for initial install
USER root

# Install S6
RUN set -xe \
    && apk add --no-cache --purge -uU curl git \
    && VERSION=$(curl -SL https://api.github.com/repos/just-containers/s6-overlay/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_v__') \
    && echo "using s6 version: ${VERSION}" \
	&& curl -o /tmp/s6-overlay-x86_64.tar.xz -jkSL   https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-x86_64.tar.xz \
	&& curl -o /tmp/s6-overlay-noarch.tar.xz -jkSL   https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz -C / \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz -C / \
	&& rm -rf /var/cache/apk/* /tmp/*

# Install arr-scripts
COPY apps/sonarr/scripts/prepare-scripts.sh /
RUN chmod 755 /prepare-scripts.sh && /prepare-scripts.sh

# USER 568

ENTRYPOINT ["/init"] # set on test or in child images
