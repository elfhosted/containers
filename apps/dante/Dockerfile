ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:8c09000173c56e1ccf19e9586b01900636f0270369cf3e7722d84b0220dafd02 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

