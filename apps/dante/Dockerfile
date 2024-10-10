ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:6ab3d945f706242c59518d185e003203de2c59702c04eebfbde6a5119f8f114a 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

