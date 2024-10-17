ARG VERSION
FROM vaultwarden/server:${VERSION}-alpine as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:4dfbee4095cde8a0d6af3e934f7be7aa64ec3901dc529cb4b455d612ce75aee7 

ENV ROCKET_PROFILE="release" \
    ROCKET_ADDRESS=0.0.0.0 \
    ROCKET_PORT=8000 \
    SSL_CERT_DIR=/etc/ssl/certs \
    I_REALLY_WANT_VOLATILE_STORAGE=true
    
# Create data folder and Install needed libraries
RUN mkdir /data \
    && apk add --no-cache \
        ca-certificates \
        curl \
        openssl \
        tzdata


VOLUME /data
EXPOSE 8000
EXPOSE 3012

# Copies the files from the context (Rocket.toml file and web-vault)
# and the binary from the "build" stage to the current stage
WORKDIR /
COPY --from=upstream /web-vault ./web-vault
COPY --from=upstream /vaultwarden ./vaultwarden
COPY --from=upstream /start.sh /start.sh

CMD ["/start.sh"]