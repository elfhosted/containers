ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:ba5334417d0d3b70c6a3314795a7780e7c51fe7e1afe16b5359e3c2902ac5895 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

