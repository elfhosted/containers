# Indelible is AGPL-3.0, so this Dockerfile lives in the public containers repo.
# ind-worker runs Indelible's background jobs (ingest, feeds, embeddings, exports).
# It has no HTTP listener; it talks to PostgreSQL, the renderer, and object storage.
#
# Same glibc constraint as ind-api: the Alpine base cannot run these binaries.
ARG VERSION
FROM ghcr.io/useindelible/ind-worker:${VERSION} AS upstream

FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:30ca54b2cccafae5c2ce2d57ab420733d3b46bbe56e58f3f382db24f993cbff1

ARG VERSION
LABEL org.opencontainers.image.source="https://github.com/useindelible/indelible"

# hadolint ignore=DL3008
RUN \
    apt-get -qq update \
    && \
    apt-get -qq install -y --no-install-recommends \
        ca-certificates \
        fonts-dejavu-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=upstream --chown=568:568 /app/ind-worker /app/ind-worker

ENV HOME=/config \
    TMPDIR=/tmp

WORKDIR /config
USER 568

CMD ["/app/ind-worker"]
