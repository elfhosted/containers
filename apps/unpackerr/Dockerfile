FROM golang:alpine as builder

ARG VERSION

RUN apk add --update --no-cache build-base git bash && \
    git clone -n https://github.com/Unpackerr/unpackerr.git /unpackerr && cd /unpackerr && \
    git checkout v${VERSION} && \
    CGO_ENABLED=0 make unpackerr.amd64.linux

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 

VOLUME /config

COPY --from=builder /unpackerr/unpackerr.amd64.linux /app/unpackerr
COPY --from=builder /unpackerr/examples/unpackerr.conf.example /app/unpackerr.conf.example
RUN chmod 755 "/app/unpackerr"

COPY ./apps/unpackerr/entrypoint.sh /
CMD ["/entrypoint.sh"]
