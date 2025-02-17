ARG VERSION
FROM ghcr.io/bluesky-social/pds:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d 

ENV S6_OVERLAY_VERSION=3.2.0.2
WORKDIR /gotosocial
COPY --from=upstream /app /app

USER root
# Add necessities for ttyd
RUN apk add --no-cache \
    ttyd \
    tmux \
    fish

# Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN chown -R elfie:elfie /run

# We need elfie to have a non-restricted shell in this case
RUN sed -i "/^elfie:/s|/sbin/nologin|/usr/bin/fish|" /etc/passwd

USER 568

WORKDIR /
# Run the application via s6
ENTRYPOINT [ "/init" ]