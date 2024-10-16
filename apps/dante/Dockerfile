ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:503c6e796fa179fb55840b93f3ab7b4274327d116cede7d07a3895ccaf4715ae 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

