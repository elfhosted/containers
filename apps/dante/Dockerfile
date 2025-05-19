ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:42c34434da805c1c907c64e360538654a84379cd5bbfba10a73870c50db44a87 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

