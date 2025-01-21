# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/rivenmedia/riven.git /source

# Until the AD PR is merged
RUN cd /source && \
    wget https://github.com/rivenmedia/riven/pull/916.patch && \
    git apply 916.patch

# Until the mediafusion fix lands in a release
RUN cd /source && \
    wget https://github.com/rivenmedia/riven/pull/976.patch && \
    git apply 976.patch    

# Builder Image for Python Dependencies
FROM python:3.11-alpine AS builder

# Install necessary build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    python3-dev \
    build-base \
    curl

# Upgrade pip and install poetry
RUN pip install --upgrade pip && pip install poetry==1.8.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY --from=cloner /source/pyproject.toml /source/poetry.lock ./
RUN touch README.md
RUN poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR

# Final Image
FROM python:3.11-alpine
LABEL name="Riven" \
      description="Riven Media Server" \
      url="https://github.com/rivenmedia/riven"

# Install system dependencies and Node.js
ENV PYTHONUNBUFFERED=1
RUN apk add --no-cache \
    curl \
    shadow \
    rclone \
    unzip \
    gcc \
    musl-dev \
    libffi-dev \
    python3-dev \
    libpq-dev \
    libtorrent \
    ttyd \
    git \
    tmux \
    dialog \
    postgresql-client \
    jq

# Create user and group
RUN addgroup -g 568 elfie && \
adduser -u 568 -G elfie -h /config -D elfie

# Install Poetry
RUN pip install poetry==1.8.3

# Set environment variable to force color output
ENV FORCE_COLOR=1
ENV TERM=xterm-256color

# Add the components for tmux-in-wetty
COPY --chown=568:568 apps/riven/riven.sh /riven/
COPY --chown=568:568 apps/riven/riven-dev.sh /riven/

COPY --chown=568:568 apps/riven/launch-tmux.sh /riven/
COPY --chown=568:568 apps/riven/launch-tmux-dev.sh /riven/

COPY --chown=568:568 apps/riven/entrypoint.sh /riven/
COPY --chown=568:568 apps/riven/entrypoint-dev.sh /riven/

COPY --chown=568:568 apps/riven/restricted.tmux.conf /riven/
COPY --chown=568:568 apps/riven/restricted-dev.tmux.conf /riven/

ADD --chmod=755 https://raw.githubusercontent.com/eficode/wait-for/master/wait-for /usr/local/bin/

USER 568
# Set working directory
WORKDIR /riven

# Copy the virtual environment from the builder stage
COPY --from=builder /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# We need this to pass testing
ENV RIVEN_DATABASE_HOST=sqlite:///riven/data/riven.db 

# Copy the rest of the application code
COPY --from=cloner /source/src/ /riven/src
COPY --from=cloner /source/pyproject.toml /source/poetry.lock /riven/

# Ensure entrypoint script is executable
RUN chmod +x /riven/entrypoint.sh

ENTRYPOINT ["/riven/entrypoint.sh"]
