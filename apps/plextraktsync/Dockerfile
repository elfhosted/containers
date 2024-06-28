# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Taxel/PlexTraktSync /source

# syntax = docker/dockerfile:1.3-labs
ARG PYTHON_VERSION=3.12
FROM python:3.12-alpine3.19 AS base
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_ROOT_USER_ACTION=ignore
WORKDIR /app

# Create minimal layer with extra tools
FROM base AS tools
RUN apk add util-linux shadow
WORKDIR /dist
RUN <<eot
install -d ./usr/bin ./usr/lib
install -p /usr/bin/setpriv ./usr/bin
install -p /usr/lib/libcap-ng.so.0 ./usr/lib
install -p /usr/lib/libbsd.so.0 ./usr/lib
install -p /usr/lib/libmd.so.0 ./usr/lib
install -p /usr/sbin/usermod /usr/sbin/groupmod ./usr/bin
eot

FROM base AS wheels
# Download wheels/sources
COPY --from=cloner source/requirements.txt .
RUN \
	--mount=type=cache,id=pip,target=/root/.cache/pip \
	pip download --dest /wheels -r requirements.txt
# Build missing wheels
RUN \
	--mount=type=cache,id=pip,target=/root/.cache/pip \
<<eot
	set -x
	set -- $(ls /wheels/*.gz /wheels/*.zip 2>/dev/null)
	if [ $# -gt 0 ]; then
		pip wheel "$@" --wheel-dir=/wheels
	fi
eot

# Install app dependencies
FROM base AS build
RUN apk add git
RUN pip install pipenv
RUN \
	--mount=type=bind,from=wheels,source=/wheels,target=/wheels \
	pipenv run pip install /wheels/*.whl

# Verify site-packages path
ARG PYTHON_VERSION
RUN du -sh /root/.local/share/virtualenvs/app-*/lib/python$PYTHON_VERSION/site-packages

FROM base AS compile
ARG APP_VERSION=$APP_VERSION
ENV APP_VERSION=$APP_VERSION

COPY --from=cloner /source/plextraktsync ./plextraktsync/
COPY --from=cloner /source/plextraktsync.sh .
# Create __version__ from $APP_VERSION
RUN echo "__version__ = '${APP_VERSION:-unknown}'" > plextraktsync/__init__.py
RUN cat plextraktsync/__init__.py
RUN python -c "from plextraktsync import __version__; print(__version__)"

# Compile sources
RUN python -m compileall .
RUN chmod -R a+rX,g-w .

FROM base AS runtime
ENTRYPOINT ["/init"]

ENV \
	# https://specifications.freedesktop.org/basedir-spec/latest/ar01s03.html
	XDG_CACHE_HOME=/app/xdg/cache \
	XDG_CONFIG_HOME=/app/xdg/config \
	XDG_DATA_HOME=/app/xdg/data \
	# https://pypa.github.io/pipx/docs/
	PIPX_BIN_DIR=/app/xdg/bin \
	PIPX_HOME=/app/xdg/pipx \
	# https://stackoverflow.com/questions/2915471/install-a-python-package-into-a-different-directory-using-pip/29103053#29103053
	PYTHONUSERBASE=/app/xdg \
	# Fallback for anything else
	HOME=/app/xdg \
	\
	PATH=/app/xdg/bin:/app/xdg/.local/bin:/root/.local/bin:$PATH \
	PTS_CONFIG_DIR=/app/config \
	PTS_CACHE_DIR=/app/config \
	PTS_LOG_DIR=/app/config \
	PTS_IN_DOCKER=1 \
	PYTHONUNBUFFERED=1

VOLUME /app/config
VOLUME $HOME

# Add user/group
RUN <<eot
	set -x
	addgroup --gid 568 --system plextraktsync
	adduser \
		--disabled-password \
		--gecos "Plex Trakt Sync" \
		--home "$(pwd)" \
		--ingroup plextraktsync \
		--no-create-home \
		--uid 568 \
		plextraktsync
eot

# Copy things together
COPY --from=tools /dist /
ARG PYTHON_VERSION
COPY --from=build /root/.local/share/virtualenvs/app-*/lib/python$PYTHON_VERSION/site-packages /usr/local/lib/python$PYTHON_VERSION/site-packages
COPY --from=compile /app ./
COPY --from=cloner /source/entrypoint.sh /init
RUN ln -s /app/plextraktsync.sh /usr/bin/plextraktsync
# https://github.com/python/cpython/issues/69667
RUN chmod a+x /root

# For image self-test
# docker build --target=test . -t app
FROM runtime AS test
ENV TRACE=1
RUN ["/init", "test"]

# default target
FROM runtime