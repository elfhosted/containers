# Indelible is AGPL-3.0, so this Dockerfile lives in the public containers repo.
# ind-renderer drives a headless Chromium ("headless-shell") for the pages that
# a plain HTTP fetch cannot archive. Upstream builds it on chromedp/headless-shell;
# we copy both the renderer binary and the pinned headless-shell tree onto the
# ElfHosted Ubuntu base, which needs only libnss3/libexpat1 added for Chromium to
# resolve its libraries. The Alpine base is not usable here either: the renderer
# binary is glibc-linked and headless-shell is a glibc build.
ARG VERSION
FROM ghcr.io/useindelible/ind-renderer:${VERSION} AS upstream

FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:30ca54b2cccafae5c2ce2d57ab420733d3b46bbe56e58f3f382db24f993cbff1

ARG VERSION
LABEL org.opencontainers.image.source="https://github.com/useindelible/indelible"

# hadolint ignore=DL3008
RUN \
    apt-get -qq update \
    && \
    apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        libnss3 \
        libexpat1 \
        fonts-liberation \
        fonts-noto-core \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=upstream /headless-shell /headless-shell
COPY --from=upstream --chown=568:568 /app/ind-renderer /app/ind-renderer

# Chromium writes its user-data-dir, crashpad database and shared memory under
# $HOME and $TMPDIR; both point at tmpfs so the root filesystem stays read-only.
ENV CHROMIUM_PATH=/headless-shell/headless-shell \
    RENDERER_HOST=0.0.0.0 \
    RENDERER_PORT=3100 \
    TZ=Etc/UTC \
    HOME=/tmp \
    TMPDIR=/tmp \
    XDG_CONFIG_HOME=/tmp \
    XDG_CACHE_HOME=/tmp

WORKDIR /tmp
USER 568
EXPOSE 3100

ENTRYPOINT []
CMD ["/app/ind-renderer"]
