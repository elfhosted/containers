ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:47653e2a1a8ab61d4666972d380ed6efa1ece6fb6dd62990f8992afe23fd41e1 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

