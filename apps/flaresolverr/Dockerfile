# Build arg to pin upstream version (e.g. --build-arg VERSION=3.3.21)
ARG VERSION
FROM ghcr.io/flaresolverr/flaresolverr:v${VERSION} AS upstream

# Copy your scripts
COPY ./apps/alpine/scripts /scripts

# Install tools and apply the patch
# - curl: fetch the patch
# - patch: apply unified diff
# - git: optional (kept since your original added it)
RUN apk add --no-cache curl patch git bash && \
    curl -fsSL \
      https://patch-diff.githubusercontent.com/raw/FlareSolverr/FlareSolverr/pull/1499.patch \
      -o /tmp/1499.patch && \
    cd /app && \
    patch -p1 < /tmp/1499.patch && \
    rm -f /tmp/1499.patch

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "source /scripts/vpn.sh && exec /usr/local/bin/python -u /app/flaresolverr.py"]
