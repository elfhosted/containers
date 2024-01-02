ARG VERSION
FROM qdm12/gluetun:v${VERSION} as upstream

COPY apps/gluetun/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]