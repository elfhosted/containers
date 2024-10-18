FROM golang:alpine as builder

ARG VERSION

RUN apk add --update --no-cache build-base git bash && \
    git clone -n https://github.com/Unpackerr/unpackerr.git /unpackerr && cd /unpackerr && \
    git checkout v${VERSION} && \
    CGO_ENABLED=0 make unpackerr.amd64.linux

FROM ghcr.io/elfhosted/alpine:rolling@sha256:8e6aef0cbeee351502e3323d5f056b5a41c962ab737e85b34878377a5ebe1e37 

VOLUME /config

COPY --from=builder /unpackerr/unpackerr.amd64.linux /app/unpackerr
COPY --from=builder /unpackerr/examples/unpackerr.conf.example /app/unpackerr.conf.example
RUN chmod 755 "/app/unpackerr"

COPY ./apps/unpackerr/entrypoint.sh /
CMD ["/entrypoint.sh"]
