ARG VERSION
FROM ghcr.io/flaresolverr/flaresolverr:v${VERSION} as upstream
COPY ./apps/alpine/scripts /scripts
COPY ./apps/flaresolverr/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
