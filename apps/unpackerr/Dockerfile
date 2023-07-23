FROM golang:alpine as builder

ARG VERSION

RUN apk add --update --no-cache build-base git bash && \
    git clone -n https://github.com/Unpackerr/unpackerr.git /unpackerr && cd /unpackerr && \
    git checkout v${VERSION} && \
    CGO_ENABLED=0 make unpackerr.amd64.linux

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:86565e3194a5e20728057da77482b2388b9b088f1921ac1a4986038730a48f01 

VOLUME /config

COPY --from=builder /unpackerr/unpackerr.amd64.linux /app/unpackerr
COPY --from=builder /unpackerr/examples/unpackerr.conf.example /app/unpackerr.conf.example
RUN chmod 755 "/app/unpackerr"

COPY ./apps/unpackerr/entrypoint.sh /
CMD ["/entrypoint.sh"]
