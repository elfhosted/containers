FROM ghcr.io/elfhosted/alpine:rolling@sha256:672b59dc4580b8aaae42e839c878501109ed7a810072c872363250930899bf16 

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl tinyproxy
# Default configuration
COPY apps/tinyproxy/entrypoint.sh /

USER 568

ENTRYPOINT ["/entrypoint.sh"]

