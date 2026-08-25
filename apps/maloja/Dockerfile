# THE RULE: app builds live in containers-private. This repo carries a Dockerfile
# or a patch series ONLY where the licence or collaborative work requires it.
# Other public copies you may find here are historical drift, not permission.
#
# Maloja meets the test: it is GPL-3.0 AND we patch it.
#
# The image is built from upstream's tree at ${VERSION} plus the patch series in
# ./patches/. Distributing a modified GPL work means offering the Corresponding
# Source, so the modification has to be public: upstream at v${VERSION}, plus
# these patches, plus this Dockerfile, is the complete recipe. Keeping the
# Dockerfile private while shipping a patched binary would not satisfy that.
#
# So for THIS app, patches are fine and both they and this file must stay public.
# That licence is the whole justification: drop ./patches/ and rebuild from an
# unmodified tree and this belongs back in containers-private. Do not cite this
# file as a precedent for making some other app's build public.
#
# ci/goss.yaml stays in containers-private, matching the usual split (ci/latest.sh
# public, ci/goss.yaml private). It is test configuration, not part of the
# Corresponding Source.
#
# Why build from source when upstream publishes krateng/maloja on Docker Hub:
# that image is lsiobase/alpine driven by s6-overlay, whose init must start as
# root in order to chown and then s6-setuidgid down to "abc" (upstream even
# defaults PUID/PGID to 0). ElfHosted runs tenant pods non-root with
# readOnlyRootFilesystem, which s6-overlay cannot survive. Installing the same
# pip package ourselves and exec'ing it directly as elfie sidesteps s6 entirely.
#
# The python floor is not a preference: pyproject.toml pins
# requires-python = "==3.12.*", so 3.13 refuses to install and any bump here
# must be checked against upstream first.

FROM public.ecr.aws/docker/library/alpine:3.21 AS cloner
ARG VERSION

RUN apk add --no-cache git
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/krateng/maloja.git /source


FROM public.ecr.aws/docker/library/python:3.12-alpine AS builder

# setproctitle, psutil, lru-dict and python-datauri have no musl wheels on
# PyPI, so they are compiled here and only the finished venv is copied forward.
# hadolint ignore=DL3018
RUN apk add --no-cache \
      gcc g++ musl-dev python3-dev libffi-dev linux-headers \
      libxml2-dev libxslt-dev git

COPY --from=cloner /source /source

# Patch series is applied in the BUILDER stage, so the installed package carries
# it -- applying it to /source alone would be a no-op once pip copies the tree.
# git apply is used rather than patch(1) so a context mismatch fails the build
# loudly instead of fuzzing the hunk into the wrong place.
COPY apps/maloja/patches/*.patch /patches/
RUN cd /source && for p in /patches/*.patch; do echo "Applying $p"; git apply --verbose "$p" || exit 1; done

RUN python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip wheel && \
    /venv/bin/pip install --no-cache-dir /source


FROM public.ecr.aws/docker/library/python:3.12-alpine
ARG VERSION
ARG APP_REVISION

LABEL org.opencontainers.image.title="Maloja" \
      org.opencontainers.image.description="Maloja: a music scrobble database with listening statistics and charts." \
      org.opencontainers.image.source="https://github.com/krateng/maloja" \
      org.opencontainers.image.documentation="https://docs.elfhosted.com/app/maloja/" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$APP_REVISION \
      org.opencontainers.image.licenses="GPL-3.0"

# libmagic backs python-magic (image type sniffing); vips is the optional
# thumbnailer; tzdata is needed because Maloja's weekly/yearly charts are
# timezone-bucketed and would otherwise all land in UTC.
# hadolint ignore=DL3018
RUN apk add --no-cache libmagic tzdata tini vips && \
    addgroup -S elfie --gid 568 && \
    adduser -S elfie -G elfie --uid 568 && \
    mkdir -p /config && \
    chown -R elfie:elfie /config

COPY --from=builder /venv /venv

# One directory for everything: with DATA_DIRECTORY set, Maloja derives config,
# state, cache and logs from it (pkg_global/conf.py), so /config holds the
# scrobble DB, the auth file, the API keys and the import/ drop folder.
ENV MALOJA_DATA_DIRECTORY=/config \
    MALOJA_CONTAINER=yes \
    PYTHONUNBUFFERED=1 \
    PATH="/venv/bin:${PATH}" \
    HOME=/tmp

# MALOJA_SKIP_SETUP is not optional. Without it, first start drops into an
# interactive prompt for API keys and a password, gets EOFError against a
# container's closed stdin, and exits.
ENV MALOJA_SKIP_SETUP=yes

# Read by elf-entrypoint.sh, NOT by Maloja: doreah's config loader ignores any
# MALOJA_* name it does not recognise (Configuration.load_environment), so this
# is safe to sit alongside the real settings. The chart overrides it; the
# default here keeps a bare `docker run` of this image usable.
ENV MALOJA_INITIAL_PASSWORD=changemeelfie

COPY apps/maloja/elf-entrypoint.sh /usr/local/bin/elf-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/elf-entrypoint.sh && \
    chmod +x /usr/local/bin/elf-entrypoint.sh

USER 568

EXPOSE 42010

# ENTRYPOINT is the wrapper and the real command is CMD, so that CI's goss run
# (which overrides the command with `tail -f /dev/null`) still executes the
# first-run password logic.
ENTRYPOINT ["/usr/local/bin/elf-entrypoint.sh"]
CMD ["/venv/bin/python", "-m", "maloja", "run"]
