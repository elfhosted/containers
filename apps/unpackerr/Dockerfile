FROM golang:alpine as builder

ARG VERSION

RUN apk add --update --no-cache build-base git bash && \
    git clone -n https://github.com/Unpackerr/unpackerr.git /unpackerr && cd /unpackerr && \
    git checkout v${VERSION} && \
    CGO_ENABLED=0 make unpackerr.amd64.linux

FROM ghcr.io/elfhosted/alpine:rolling@sha256:1ab7fc4fac80c3313d9c1178b32429c2a92644d93369a145ee497d86dd8d9bbc 

VOLUME /config

COPY --from=builder /unpackerr/unpackerr.amd64.linux /app/unpackerr
COPY --from=builder /unpackerr/examples/unpackerr.conf.example /app/unpackerr.conf.example
RUN chmod 755 "/app/unpackerr"

COPY ./apps/unpackerr/entrypoint.sh /
CMD ["/entrypoint.sh"]
