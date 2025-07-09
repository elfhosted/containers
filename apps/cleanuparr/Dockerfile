ARG VERSION

FROM ghcr.io/cleanuparr/cleanuparr:${VERSION} as upstream

# Make it run as elfie
RUN \
    adduser elfie \
        --uid 568 \
        --group \
        --system \
        --disabled-password \
        --no-create-home 
    && chown -R elfie:elfie /app \
