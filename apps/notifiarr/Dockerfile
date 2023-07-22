ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:487b892722a9e3c8e46eeddd890eb0ab039aa71c2339220164628094863bf5ad 

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