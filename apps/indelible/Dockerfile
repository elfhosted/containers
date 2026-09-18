# Indelible is AGPL-3.0, so this Dockerfile lives in the public containers repo.
# Upstream publishes release images; we lift the release binary and the built SPA
# out of theirs and drop them on the ElfHosted base so the app runs as elfie (568)
# with a read-only root filesystem.
#
# The binaries are glibc-linked (upstream builds on debian:bookworm-slim), so the
# Alpine base is not an option: even with gcompat, ind-api dies at start with
# "Error relocating /app/ind-api: __res_init: symbol not found".
ARG VERSION
FROM ghcr.io/useindelible/ind-api:${VERSION} AS upstream

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

COPY --from=upstream --chown=568:568 /app/ind-api /app/ind-api
COPY --from=upstream --chown=568:568 /app/web /app/web

# ind-api keeps every byte of state in PostgreSQL and (optionally) S3: there is no
# on-disk data directory to relocate. /config is the working directory purely so an
# operator-supplied configurations/base.toml is found, and so nothing the process
# does lands on the read-only root filesystem.
ENV IND_HOST=0.0.0.0 \
    IND_PORT=8080 \
    WEB_ROOT=/app/web \
    HOME=/config \
    TMPDIR=/tmp

WORKDIR /config
USER 568
EXPOSE 8080

CMD ["/app/ind-api"]
