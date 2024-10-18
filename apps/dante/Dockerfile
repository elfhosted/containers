ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:0782c9e41d6e1efe014e1081a12f9f25665aa9b18372de4bd9bb848ace53cceb 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

