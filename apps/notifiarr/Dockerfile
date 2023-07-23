ARG VERSION
FROM golift/notifiarr:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:22c9c87f4e72199aeb63d30175dfed98d97e03797775dd6f9167adf0da3326ed 

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