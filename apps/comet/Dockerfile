FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# RUN git clone -b $VERSION https://github.com/g0ldyy/comet.git /source

RUN git clone https://github.com/elfhosted/comet.git /source


# Patch out requirement for warp
COPY apps/comet/no-warp-necessary.patch /source/
RUN cd /source && git apply no-warp-necessary.patch && rm no-warp-necessary.patch

FROM python:3.11-alpine
LABEL name="Comet" \
    description="Stremio's fastest torrent/debrid search add-on." \
    url="https://github.com/g0ldyy/comet"

WORKDIR /app

ARG DATABASE_PATH

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_HOME="/usr/local" \
    FORCE_COLOR=1 \
    TERM=xterm-256color \
    PYTHONPATH=/app \
    INDEXER_MANAGER_INDEXERS='["DMM public hash shares only"]' \
    INDEXER_MANAGER_API_KEY='fakeapikey'

# Fix python-alpine gcc
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    make

RUN \
    addgroup -S elfie --gid 568 \
    && adduser -S elfie -G elfie --uid 568 \
    && chown elfie -R /app


USER 568


# Install poetry to user-accessible location
RUN pip install --user poetry

# Copy dependency files
COPY --from=cloner /source/pyproject.toml /source/poetry.lock* ./

# Update dependencies to include gunicorn if not already present
RUN ~/.local/bin/poetry add gunicorn

# Install dependencies
RUN ~/.local/bin/poetry install --no-cache --no-root --without dev

# Copy application code
COPY --from=cloner /source/. .

ENTRYPOINT ["/home/elfie/.local/bin/poetry", "run", "gunicorn", "comet.main:app", \
    "--config", "comet/gunicorn_conf.py", \
    "--worker-class", "uvicorn.workers.UvicornWorker"]