ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:abe1c6726d152183da7903907260981392b0feb43bb8238e174a4dbaddcd2f53 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

