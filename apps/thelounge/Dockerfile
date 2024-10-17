ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856 

ENV NODE_ENV production

ENV THELOUNGE_HOME "/config-bootstrap"
VOLUME "${THELOUNGE_HOME}"

RUN apk add --update --no-cache --virtual build-deps python3 build-base git && \
    apk add --update --no-cache yarn npm && \
    ln -sf python3 /usr/bin/python && \
    yarn --non-interactive --frozen-lockfile global add thelounge@${VERSION} && \
    yarn --non-interactive cache clean && \
    timeout 5s thelounge start && \
    for i in $(npm search thelounge-theme -p | cut -f1); do \
        thelounge install $i; \
    done && \
    for i in $(npm search thelounge-plugin -p | cut -f1); do \
        thelounge install $i; \
    done && \
    chown 568:568 //config-bootstrap -R && \
    apk del --purge build-deps && \
    rm -rf /root/.cache /tmp /usr/bin/python

# Expose HTTP
ENV PORT 9000
EXPOSE ${PORT}
USER 568
ENV THELOUNGE_HOME "/config"
COPY ./apps/thelounge/entrypoint.sh /
CMD ["/entrypoint.sh"]
