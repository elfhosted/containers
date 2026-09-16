# Vikunja: a to-do and project management app.
#
# This Dockerfile is PUBLIC (unlike most ElfHosted build configs) because
# Vikunja is licensed AGPL-3.0, and the build recipe for the image we run is
# part of the corresponding source we make available.
#
# Vikunja ships as a single statically linked Go binary with the frontend
# embedded. Upstream's official image is FROM scratch, runs as uid 1000 and
# keeps its database under /db, so we copy the unmodified release binary out of
# it into our alpine base, run as elfie (568), and point all state at /config.
# No source patches.

ARG VERSION
FROM vikunja/vikunja:${VERSION} AS upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:f6ba42afb0be46de3fec300aed6a542f892ad822c357f044eb6a96d9a36661c1

# The base already provides elfie (568), /config, ca-certificates, tzdata and tini.
COPY --from=upstream /app/vikunja/vikunja /app/vikunja/vikunja

# All persistent state lives under /config (sqlite db, uploaded files,
# plugins). Nothing is written to the image filesystem, so the container runs
# with a read-only rootfs.
# VIKUNJA_SERVICE_SECRET is deliberately NOT set here: it signs JWTs, and when
# unset Vikunja generates a random one on every start (logging everyone out on
# each restart). The chart must supply a stable per-tenant value.
# VIKUNJA_SERVICE_PUBLICURL is mandatory (Vikunja exits at startup without it
# while CORS is enabled, which is the default). The localhost value only exists
# so the image boots standalone for CI; the chart must override it with the
# tenant's real URL, since it is used in emails, CalDAV and OIDC redirects.
ENV VIKUNJA_SERVICE_INTERFACE=":3456" \
    VIKUNJA_SERVICE_PUBLICURL="http://localhost:3456/" \
    VIKUNJA_SERVICE_ROOTPATH="/config" \
    VIKUNJA_DATABASE_TYPE="sqlite" \
    VIKUNJA_DATABASE_PATH="/config/vikunja.db" \
    VIKUNJA_FILES_BASEPATH="/config/files" \
    VIKUNJA_LOG_PATH="/config/logs" \
    VIKUNJA_PLUGINS_DIR="/config/plugins" \
    TMPDIR="/tmp"

WORKDIR /app/vikunja

USER 568

EXPOSE 3456

ENTRYPOINT ["/sbin/tini", "--", "/app/vikunja/vikunja"]
