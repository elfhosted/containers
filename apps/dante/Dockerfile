ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:c104de5b07c8ee57c9d02d21c06929e3f006f689d5c601628dbec8528d844065 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

