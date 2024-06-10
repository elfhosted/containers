ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3d8693e2e68a277e14e96594381f8b8620c81ada3827babb842faeaae607693f 

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