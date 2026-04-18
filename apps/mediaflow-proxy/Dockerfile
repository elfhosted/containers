# Downloader stage: grab the architecture-appropriate prebuilt binary from
# the upstream GitHub release. mediaflow-proxy-light is a Rust binary;
# using the release artifacts avoids running the Rust toolchain under QEMU.
FROM alpine:3.21 AS downloader

ARG CHANNEL
ARG VERSION
ARG TARGETPLATFORM

RUN apk add --no-cache curl ca-certificates

WORKDIR /tmp

RUN case "${TARGETPLATFORM:-linux/amd64}" in \
        "linux/amd64") BINARY_NAME="mediaflow-proxy-light-linux-x86_64" ;; \
        "linux/arm64") BINARY_NAME="mediaflow-proxy-light-linux-aarch64" ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" >&2; exit 1 ;; \
    esac && \
    curl -fL --retry 3 --retry-delay 2 \
        -o mediaflow-proxy-light \
        "https://github.com/mhdzumair/mediaflow-proxy-light/releases/download/${VERSION}/${BINARY_NAME}" && \
    chmod +x mediaflow-proxy-light

# Fetch the example config at the same version (upstream bakes it into the image)
RUN curl -fL --retry 3 --retry-delay 2 \
        -o config.toml \
        "https://raw.githubusercontent.com/mhdzumair/mediaflow-proxy-light/${VERSION}/config-example.toml"

# Runtime stage: distroless/cc-debian12 provides glibc + libgcc required by
# the Rust binary (links libstdc++ via rquest's boring-sys). ~20 MB total.
FROM gcr.io/distroless/cc-debian12

WORKDIR /app

COPY --from=downloader --chown=568:568 /tmp/mediaflow-proxy-light /app/
COPY --from=downloader --chown=568:568 /tmp/config.toml /app/config.toml

ENV RUST_LOG=info
ENV CONFIG_PATH=/app/config.toml

USER 568:568

EXPOSE 8888

ENTRYPOINT ["/app/mediaflow-proxy-light"]
