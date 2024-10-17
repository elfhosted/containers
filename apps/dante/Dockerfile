ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:adba843c93f612e67aa9745d8cc7a9ed17bfd11501d778c3cd115267fc59d4d1 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

