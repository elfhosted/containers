ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:bf24106fa491cfbf45ffd9d7f51d2c427eecf8e540df6ab6fa1693b10d1d7105 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

