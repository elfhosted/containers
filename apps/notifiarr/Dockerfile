ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:523b82a80cbc42de1b430e84afff4c09b377387d3d0fb2e43ba7317d49d84607 

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