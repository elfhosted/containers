ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:f5e27001ebd22ad35f1a30d7d7e127b61273ae9c64666aee8ad37c522b7bae1a 

# Create data folder and Install needed libraries
RUN apk add --no-cache \
        ca-certificates \
        curl \
        openssl \
        tzdata

# Make sure we have an ssl cert chain and timezone data.
COPY --from=upstream /image /notifiarr

ENV TZ=UTC

# Notifiarr specific.
# ENV PATH=$PATH:/
ENV USER=elfie

EXPOSE 5454
ENTRYPOINT [ "/notifiarr" ]