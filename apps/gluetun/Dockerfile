ARG VERSION
FROM qmcgaw/gluetun:v${VERSION} as upstream

COPY apps/gluetun/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]