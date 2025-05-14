FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c3dbccc25e349861a983e12ab7c2b2f14a6365dacbe2c500a819dd103164af6 

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl tinyproxy
# Default configuration
COPY apps/tinyproxy/entrypoint.sh /

USER 568

ENTRYPOINT ["/entrypoint.sh"]

