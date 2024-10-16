ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:05a4a21c5a2f0a133ba338fe802e0565bd2b9b0da7aac7a254df2e5833511900 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

