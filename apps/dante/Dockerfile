ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:6a02d1eae6b2c3b5d76befe1009944c36156fdf536f46ef57c47e2259b81ab1a 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

