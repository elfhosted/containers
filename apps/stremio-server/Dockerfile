ARG VERSION
FROM docker.io/stremio/server:${VERSION} as upstream

COPY ./apps/alpine/scripts/vpn.sh /scripts/vpn.sh
COPY ./apps/stremio-server/entrypoint.sh /entrypoint.sh
CMD []
ENTRYPOINT ["/entrypoint.sh"]