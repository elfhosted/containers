ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:a56135e0488267f3b18bc4ada6c39b67e5c9657aeced224a67b173764c6ea80b 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

