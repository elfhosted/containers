ARG VERSION=1.4.3
FROM ghcr.io/elfhosted/alpine:rolling@sha256:672b59dc4580b8aaae42e839c878501109ed7a810072c872363250930899bf16 

ENV workers 1

# Install dante-server, sockd user will be created
RUN apk add --no-cache curl linux-pam dumb-init dante-server
# Default configuration
COPY apps/dante/conf/sockd-no-auth.conf /etc/sockd.conf

EXPOSE 2020

USER 568

ENTRYPOINT ["dumb-init"]
CMD ["sh", "-c", "sockd -N ${workers}"]

