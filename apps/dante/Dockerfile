ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c3dbccc25e349861a983e12ab7c2b2f14a6365dacbe2c500a819dd103164af6 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

