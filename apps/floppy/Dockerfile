# THE RULE: app builds live in containers-private. This repo carries a Dockerfile
# or supporting build files ONLY where the licence or collaborative work requires
# it. Other public copies you may find here are historical drift, not permission.
#
# Floppy meets the test: it is AGPL-3.0. AGPL section 13 extends the
# Corresponding Source obligation to users who interact with the program over a
# network, which is exactly how a hosted instance is used. The build recipe we
# run it with (this Dockerfile, the launcher and the nginx config beside it) is
# part of what we offer, so it lives here in public: upstream at v${VERSION}
# plus the files in this directory is the complete recipe.
#
# patches/ holds the only changes to upstream source, applied in order right
# after the clone. They are git format-patch output against the tag, so they can
# be offered upstream as is:
#   0001-0003  TMDB_BASE_URL, TVDB_BASE_URL and TVMAZE_BASE_URL, each defaulting
#              to the public API, so a provider can be pointed at a compatible
#              mirror or caching proxy. The TVDB and TVMaze rate limiters follow
#              the configured URL.
# A version bump must re-check that every patch still applies; the build fails
# if one does not.
#
# ci/goss.yaml stays in containers-private, matching the usual split (ci/latest.sh
# public, ci/goss.yaml private). It is test configuration, not Corresponding Source.
#
# Why not upstream's ghcr.io/dannyvfilms/floppy image: its entrypoint runs as
# root to usermod/groupmod/chown a PUID/PGID user, then supervisord (as root)
# starts nginx as root and drops the Python processes to "abc". This image
# instead runs every process as 568 under a read-only root filesystem:
#   - tini is PID 1 and runs elf-entrypoint.sh, which runs upstream's SQLite
#     startup check and migrations, then starts nginx (:8000), gunicorn
#     (127.0.0.1:8001) and the celery workers upstream's sizing logic selects,
#     exiting (so the pod restarts) as soon as any one of them dies.
#   - nginx's pid, temp paths and rendered config live in /tmp.
#   - /floppy/db (upstream's FLOPPY_DATA_DIR: SQLite, logs, generated secret,
#     image cache, import staging) is a build-time symlink to /config, and
#     /floppy/backups (scheduled CSV exports and SQLite snapshots) to
#     /config/backups, so /config is the one volume. This matches upstream's
#     compose file, which mounts ./db at /floppy/db, so an existing upstream db/
#     directory can be dropped into /config as is.
#
# Python/Alpine/uv versions and the uv invocation mirror upstream's Dockerfile at
# the tag; bump them only when upstream does.

ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.24

FROM public.ecr.aws/docker/library/alpine:${ALPINE_VERSION} AS cloner
ARG VERSION

RUN apk add --no-cache git
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/dannyvfilms/floppy.git /source

# Apply every patch, failing the build on the first one that does not apply. A
# plain "for ...; do git apply ...; done" would only report the last status.
COPY apps/floppy/patches/ /patches/
RUN set -e; \
    cd /source; \
    for p in /patches/*.patch; do \
      echo "Applying ${p}"; \
      git apply "${p}" || exit 1; \
    done


# Both stages must use the same Python version, otherwise the virtualenv copied
# from the builder ends up in a site-packages path the runtime Python ignores.
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder

COPY --from=ghcr.io/astral-sh/uv:0.12.3 /uv /uvx /bin/
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/opt/venv

WORKDIR /floppy

# Upstream installs the bundled MCP server (mcp_server/, a uv workspace member)
# into the same venv. It is a stdio program with no listener: nothing starts it,
# and it can only be run deliberately with `kubectl exec`.
COPY --from=cloner /source/pyproject.toml /source/uv.lock ./
COPY --from=cloner /source/mcp_server/pyproject.toml ./mcp_server/pyproject.toml
RUN uv sync --locked --no-default-groups --no-install-workspace

COPY --from=cloner /source/mcp_server ./mcp_server
RUN uv sync --locked --no-default-groups --no-editable


FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}
ARG VERSION
ARG APP_REVISION

LABEL org.opencontainers.image.title="Floppy" \
      org.opencontainers.image.description="Floppy: a self-hosted tracker for movies, TV, anime, manga, books, comics, games, music and podcasts." \
      org.opencontainers.image.source="https://github.com/dannyvfilms/floppy" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$APP_REVISION \
      org.opencontainers.image.licenses="AGPL-3.0"

# hadolint ignore=DL3018
RUN apk add --no-cache bash nginx tini && \
    addgroup -S elfie --gid 568 && \
    adduser -S elfie -G elfie --uid 568 && \
    mkdir -p /config && \
    chown elfie:elfie /config

# VERSION/COMMIT_SHA are read by settings.py (About page, update checks).
# FLOPPY_PORT=8000 makes the environment own the listener, so Settings >
# Advanced cannot save a port this image's fixed nginx config would ignore.
# FLOPPY_URL is the bundled MCP server's default target.
# ALLOWED_HOSTS mirrors upstream's Docker default ("*" when /.dockerenv
# exists, which it does not under Kubernetes); without it kubelet probes and
# in-cluster health checks, which use the pod IP or service name as Host, get 400.
ENV VERSION=$VERSION \
    COMMIT_SHA=$APP_REVISION \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/tmp \
    FLOPPY_PORT=8000 \
    FLOPPY_URL=http://127.0.0.1:8000 \
    ALLOWED_HOSTS="*"

RUN printf 'VERSION=%s\nCOMMIT_SHA=%s\n' "${VERSION}" "${APP_REVISION:-unknown}" > /etc/floppy-build-info && \
    mkdir -p /etc/floppy && \
    printf 'dannyvfilms' > /etc/floppy/fork_owner

WORKDIR /floppy

COPY --from=builder /opt/venv /opt/venv
COPY --from=cloner /source/src/ /floppy/
COPY --from=cloner /source/mcp_server/ /floppy/mcp_server/

# collectstatic imports settings.py, which mkdirs /floppy/db/logs as a side
# effect; that directory is then replaced by the /config symlink. The app tree is
# byte-compiled here because PYTHONDONTWRITEBYTECODE (and the read-only rootfs)
# stop it happening at runtime. Upstream's "/yamtrack -> /floppy" compat
# symlink is for bind mounts at the old path, which we never use.
# /health/full/'s storage check writes a probe file through Django's default
# storage, which (MEDIA_ROOT unset) is the working directory, /floppy. The
# symlink sends it to /tmp, which elf-entrypoint.sh creates.
RUN ln -s /opt/venv /floppy/.venv && \
    SECRET=build-time-placeholder python manage.py collectstatic --noinput && \
    python -m compileall -q /floppy && \
    rm -rf /floppy/db /floppy/backups && \
    ln -s /config /floppy/db && \
    ln -s /config/backups /floppy/backups && \
    ln -s /tmp/health_check_storage_test /floppy/health_check_storage_test

COPY apps/floppy/nginx.conf /etc/nginx/floppy.conf
COPY apps/floppy/elf-entrypoint.sh /usr/local/bin/elf-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/elf-entrypoint.sh && \
    chmod +x /usr/local/bin/elf-entrypoint.sh

USER 568

EXPOSE 8000

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/elf-entrypoint.sh"]
