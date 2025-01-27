ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:abe1c6726d152183da7903907260981392b0feb43bb8238e174a4dbaddcd2f53 

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