FROM ghcr.io/elfhosted/alpine:rolling@sha256:abe1c6726d152183da7903907260981392b0feb43bb8238e174a4dbaddcd2f53 

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl tinyproxy
# Default configuration
COPY apps/tinyproxy/entrypoint.sh /

USER 568

ENTRYPOINT ["/entrypoint.sh"]

