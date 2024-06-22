ARG VERSION
FROM ghcr.io/flaresolverr/flaresolverr:v${VERSION} as upstream
COPY ./apps/alpine/scripts /scripts

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "source /scripts/vpn.sh && exec /usr/local/bin/python -u /app/flaresolverr.py"]