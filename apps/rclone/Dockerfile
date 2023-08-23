ARG VERSION
FROM ghcr.io/geek-cookbook/alpine:edge@sha256:e3c6418b5a0b2b9f2dae2265e98fd6416dc5ce551dc63ff382bff52de7893e37

# Install S6
RUN set -xe \
    && apk add --no-cache --purge -uU curl \
    && VERSION=$(curl -SL https://api.github.com/repos/just-containers/s6-overlay/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_v__') \
    && echo "using s6 version: ${VERSION}" \
	&& curl -o /tmp/s6-overlay-x86_64.tar.xz -jkSL   https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-x86_64.tar.xz \
	&& curl -o /tmp/s6-overlay-noarch.tar.xz -jkSL   https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz -C / \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz -C / \
	&& rm -rf /var/cache/apk/* /tmp/*

# Define build arguments
ARG RCLONE_VERSION=current

# Define environment variables
ENV ARCH=amd64

# Define working directory.
WORKDIR /tmp

# # Install rclone via alpine
# RUN if [ -z ${VERSION+x} ]; then \
#     VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
#     && awk '/^P:rclone$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
#     fi && \
#     echo installing rclone ${VERSION}... \
#     apk add -U --upgrade --no-cache \
#     rclone~=${VERSION} 

RUN apk add --no-cache rclone

RUN curl -o /tmp/rclone-rc-web-gui.zip -jkSL https://github.com/retifrav/rclone-rc-web-gui/releases/download/v0.4.0/rclone-rc-web-gui.zip \
    && unzip /tmp/rclone-rc-web-gui.zip \
    && mv /tmp/build /var/lib/rclonefm \
    && rm -r /tmp/rclone-rc-web-gui.zip \
    && apk del --purge curl

# Add files.
COPY apps/rclone/rootfs/ /

ENTRYPOINT ["/init"] # set on test or in child images
