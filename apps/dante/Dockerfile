ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:627245a90cbfe877d2beddadcc00e0af149b26ef38bd2956a35ee999e2d1c556 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

