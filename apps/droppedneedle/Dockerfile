ARG VERSION

# Clone upstream at VERSION, apply patches/*.patch, rebuild the two server
# binaries and copy them into upstream's published image. Everything else in
# the image is upstream's.
FROM alpine:latest AS cloner
ARG VERSION
RUN apk add --no-cache git
RUN git clone --depth 1 -b ${VERSION} https://github.com/DroppedNeedle/DroppedNeedle.git /source
COPY apps/droppedneedle/patches/*.patch /patches/
# 01-cache-endpoints.patch: AUDIODB_API_BASE, LISTENBRAINZ_API_BASE,
# MUSICBRAINZ_API_BASE (BrainzMash) and MUSICBRAINZ_OFFICIAL_API_BASE replace
# those API roots, and AUDIODB_RATE_LIMIT_RPS replaces TheAudioDB's free-key
# rate. Each unset keeps upstream's behaviour.
RUN set -e; cd /source; for p in /patches/*.patch; do echo "Applying $p..."; git apply "$p"; done

# Upstream's own build of the binaries (the "builder" stage of its
# Dockerfile). rust-toolchain.toml pins the compiler. Bookworm, as upstream's
# runtime image is.
FROM rust:1-bookworm AS builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends cmake \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV LIBSQLITE3_FLAGS=-DSQLITE_DEFAULT_MEMSTATUS=0
COPY --from=cloner /source/rust-toolchain.toml ./
COPY --from=cloner /source/server/ ./server/
COPY --from=cloner /source/sdk/ ./sdk/
COPY --from=cloner /source/frontend/src/lib/stores/customCssRules.json ./frontend/src/lib/stores/customCssRules.json
RUN cargo build --release --locked --manifest-path server/Cargo.toml --bins -p droppedneedle -p droppedneedle-tool \
    && mkdir /out \
    && cp server/target/release/droppedneedle server/target/release/droppedneedle-tool /out/ \
    && rm -rf server/target

FROM ghcr.io/droppedneedle/droppedneedle:${VERSION}
COPY --from=builder /out/droppedneedle /usr/local/bin/droppedneedle
COPY --from=builder /out/droppedneedle-tool /usr/local/bin/droppedneedle-tool
# Fails the build if the rebuilt binaries cannot load against the image's
# libraries.
RUN droppedneedle-tool --help >/dev/null
LABEL org.opencontainers.image.source="https://github.com/DroppedNeedle/DroppedNeedle"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
