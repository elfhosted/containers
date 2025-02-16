ARG VERSION
FROM uperseriousbusiness/gotosocial:${VERSION} as upstream
FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d 

COPY chown=568:568 --from=upstream /gotosocial /gotosocial
ENTRYPOINT [ "/gotosocial/gotosocial", "server", "start" ]

