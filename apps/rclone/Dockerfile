ARG VERSION
FROM ghcr.io/geek-cookbook/alpine:edge@sha256:6b59b2060ffbb6af76654aae9f5185fbfdfb08b2532d0186f3b14e8ad26b7598

ENV TZ="UTC" \
  PUID="568" \
  PGID="568"

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
    && mv /tmp/build /var/lib/rclonefm

RUN curl -o /tmp/rcloneui.zip -jkSL https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip \
    && unzip /tmp/rcloneui.zip \
    && mv /tmp/build /var/lib/rcloneui

RUN curl -o /tmp/rclone-webui-angular.zip -jkSL https://github.com/yuudi/rclone-webui-angular/releases/download/v0.7.0/embed.zip \
    && unzip /tmp/rclone-webui-angular.zip \
    && mv /tmp/build /var/lib/rclonewebui \
    && rm -r /tmp/rclone-* \
    && apk del --purge curl    




# Add files.
COPY apps/rclone/rootfs/ /

ENTRYPOINT ["/init"] # set on test or in child images
