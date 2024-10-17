ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:4dccd868574f5595117642045ab574ed4ca628b43c8680ed253c422de1362a9b 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

