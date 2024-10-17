ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:d143aa2ae054d1061cb6abc8a820506c90330e51fcc95dc7b7f4d2462b61ed3a 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

