# THE RULE: app builds live in containers-private. This repo carries a Dockerfile
# or supporting build files ONLY where the licence or collaborative work requires
# it. Other public copies you may find here are historical drift, not permission.
#
# Yamtrack meets the test: it is AGPL-3.0. AGPL section 13 extends the
# Corresponding Source obligation to users who interact with the program over a
# network, which is exactly how a hosted instance is used. The build recipe we
# run it with (this Dockerfile, the launcher and the nginx config beside it) is
# part of what we offer, so it lives here in public: upstream at v${VERSION}
# plus the files in this directory is the complete recipe.
#
# patches/ holds the only changes to upstream source, applied in order right
# after the clone. They are git format-patch output against the tag, so they can
# be offered upstream as is:
#   0001-0004  TMDB_BASE_URL, TVDB_BASE_URL and TVMAZE_BASE_URL, each defaulting
#              to the public API, so a provider can be pointed at a compatible
#              mirror or caching proxy. The TVMaze rate limiter follows the
#              configured URL.
# A version bump must re-check that every patch still applies; the build fails
# if one does not.
#
# ci/goss.yaml stays in containers-private, matching the usual split (ci/latest.sh
# public, ci/goss.yaml private). It is test configuration, not Corresponding Source.
#
# Why not upstream's ghcr.io/fuzzygrim/yamtrack image: its entrypoint runs as
# root to usermod/groupmod/chown a PUID/PGID user, then supervisord (as root)
# starts nginx as root and drops the Python processes to "abc". This image
# instead runs every process as 568 under a read-only root filesystem:
#   - tini is PID 1 and runs elf-entrypoint.sh, which migrates the SQLite DB and
#     starts nginx (:8000), gunicorn (127.0.0.1:8001), celery worker and celery
#     beat, exiting (so the pod restarts) as soon as any one of them dies.
#   - nginx's pid, temp paths and rendered config live in /tmp.
#   - /yamtrack/db (where settings.py hardcodes the SQLite file when DB_HOST is
#     unset) is a build-time symlink to /config, so /config is the one volume.
#     This matches upstream's compose file, which mounts ./db at /yamtrack/db,
#     so an existing upstream db/ directory can be dropped into /config as is.
#
# Python/Alpine versions and the uv invocation mirror upstream's Dockerfile at
# the tag; bump them only when upstream does.

ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.23

FROM public.ecr.aws/docker/library/alpine:${ALPINE_VERSION} AS cloner
ARG VERSION

RUN apk add --no-cache git
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/FuzzyGrim/Yamtrack.git /source

# Apply every patch, failing the build on the first one that does not apply. A
# plain "for ...; do git apply ...; done" would only report the last status.
COPY apps/yamtrack/patches/ /patches/
RUN set -e; \
    cd /source; \
    for p in /patches/*.patch; do \
      echo "Applying ${p}"; \
      git apply "${p}" || exit 1; \
    done


# Both stages must use the same Python version, otherwise the virtualenv copied
# from the builder ends up in a site-packages path the runtime Python ignores.
FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder

ENV UV_NO_DEV=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /yamtrack

COPY --from=cloner /source/pyproject.toml /source/uv.lock ./
RUN uv sync --locked


FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}
ARG VERSION
ARG APP_REVISION

LABEL org.opencontainers.image.title="Yamtrack" \
      org.opencontainers.image.description="Yamtrack: a media tracker for movies, TV, anime, manga, games, books, comics and board games." \
      org.opencontainers.image.source="https://github.com/FuzzyGrim/Yamtrack" \
      org.opencontainers.image.documentation="https://docs.elfhosted.com/app/yamtrack/" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$APP_REVISION \
      org.opencontainers.image.licenses="AGPL-3.0"

# hadolint ignore=DL3018
RUN apk add --no-cache bash nginx tini && \
    addgroup -S elfie --gid 568 && \
    adduser -S elfie -G elfie --uid 568 && \
    mkdir -p /config && \
    chown elfie:elfie /config

# VERSION is read by settings.py and shown on the About page.
ENV VERSION=$VERSION \
    PATH="/yamtrack/.venv/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/tmp

WORKDIR /yamtrack

COPY --from=builder /yamtrack/.venv /yamtrack/.venv
COPY --from=cloner /source/src/ /yamtrack/

# collectstatic imports settings.py, which mkdirs /yamtrack/db as a side effect;
# that directory is then replaced by the /config symlink. The app tree is
# byte-compiled here because PYTHONDONTWRITEBYTECODE (and the read-only rootfs)
# stop it happening at runtime.
RUN python manage.py collectstatic --noinput && \
    python -m compileall -q /yamtrack/app /yamtrack/config /yamtrack/events \
      /yamtrack/integrations /yamtrack/lists /yamtrack/users /yamtrack/manage.py && \
    rm -rf /yamtrack/db && \
    ln -s /config /yamtrack/db

COPY apps/yamtrack/nginx.conf /etc/nginx/yamtrack.conf
COPY apps/yamtrack/elf-entrypoint.sh /usr/local/bin/elf-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/elf-entrypoint.sh && \
    chmod +x /usr/local/bin/elf-entrypoint.sh

USER 568

EXPOSE 8000

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/elf-entrypoint.sh"]
