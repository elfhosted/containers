# Wealthfolio (web/server mode), AGPL-3.0: this Dockerfile is public.
#
# We redistribute the UNMODIFIED official release. The server binary and web
# frontend are copied verbatim from upstream's official image
# (wealthfolio/wealthfolio, published by upstream's release workflow). No
# patches and no brand changes, per https://github.com/wealthfolio/wealthfolio/blob/main/TRADEMARKS.md
# ("Redistribute unmodified official Wealthfolio builds"). Do not patch this app;
# a modified build would have to be renamed and de-branded.
#
# The official image is Alpine/musl, and the binary links only against musl
# (OpenSSL/SQLCipher are static), so it runs as-is on our Alpine base.
ARG VERSION
FROM wealthfolio/wealthfolio:${VERSION} AS upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:f6ba42afb0be46de3fec300aed6a542f892ad822c357f044eb6a96d9a36661c1

# WF_DB_PATH also sets the data root: secrets.json (encrypted vault), addons,
# logs and backups all live beside the database, so everything persists in /config.
# CONNECT_API_URL matches the value baked into the official image.
ENV WF_LISTEN_ADDR=0.0.0.0:8088 \
    WF_DB_PATH=/config/wealthfolio.db \
    WF_STATIC_DIR=/app/dist \
    CONNECT_API_URL=https://api.wealthfolio.app \
    TMPDIR=/tmp

WORKDIR /app

COPY --from=upstream /usr/local/bin/wealthfolio-server /usr/local/bin/wealthfolio-server
COPY --from=upstream /app/dist /app/dist

USER 568:568

VOLUME ["/config"]
EXPOSE 8088

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/wealthfolio-server"]
