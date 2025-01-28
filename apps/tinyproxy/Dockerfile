FROM ghcr.io/elfhosted/alpine:rolling@sha256:9fe67d87930b27bf9f7743ac1a4fe4d6b614d3ac94420babdffe243888a3e36d 

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl tinyproxy
# Default configuration
COPY apps/tinyproxy/entrypoint.sh /

USER 568

ENTRYPOINT ["/entrypoint.sh"]

