ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856 

# Create data folder and Install needed libraries
RUN apk add --no-cache \
        ca-certificates \
        curl \
        openssl \
        tzdata

# Make sure we have an ssl cert chain and timezone data.
COPY --from=upstream /notifiarr /notifiarr

ENV TZ=UTC

# Notifiarr specific.
# ENV PATH=$PATH:/
ENV USER=elfie

EXPOSE 5454
ENTRYPOINT [ "/notifiarr" ]