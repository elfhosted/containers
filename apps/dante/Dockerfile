ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:97d4184c307315f0e099d09921eccc1c240ad362f835dd0a44d789927116bec0 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

