ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:c104de5b07c8ee57c9d02d21c06929e3f006f689d5c601628dbec8528d844065 

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