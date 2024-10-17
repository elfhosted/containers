ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:613831c1627a38d1b2e3b91870ff4fd8537548e2911ebc9b20c53ea0c012aea6 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

