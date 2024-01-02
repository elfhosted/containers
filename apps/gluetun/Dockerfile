ARG VERSION
FROM qmcgaw/gluetun:v${VERSION} as upstream

RUN apk --no-cache add bind-tools 

COPY apps/gluetun/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]