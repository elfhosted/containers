ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:a03913e04428c49195fa0b4c9a6e7cfad889692b4839937b387b0a2a06f25733 

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