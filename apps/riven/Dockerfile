# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/rivenmedia/riven.git /source

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
RUN pip install --upgrade pip && pip install poetry==1.4.2

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY --from=cloner /source/pyproject.toml /source/poetry.lock ./
RUN touch README.md
RUN poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR

# Frontend Builder
FROM node:20-alpine AS frontend
WORKDIR /app
COPY --from=cloner /source/frontend/package*.json ./
RUN npm install -g pnpm && pnpm install
COPY --from=cloner /source/frontend/ .
RUN pnpm run build && pnpm prune --prod

# Final Image
# FROM python:3.11-alpine
FROM wettyoss/wetty
LABEL name="Iceberg" \
      description="Iceberg Debrid Downloader" \
      url="https://github.com/dreulavelle/iceberg"

# Install system dependencies and Node.js
ENV PYTHONUNBUFFERED=1
RUN apk add --no-cache \
    curl \
    fish \
    shadow \
    nodejs \
    dumb-init \
    npm \
    rclone \
    fontconfig \
    unzip \
    gcc \
    musl-dev \
    libffi-dev \
    py3-pip \
    tmux \
    python3-dev && \
    npm install -g pnpm

# Install Nerd Fonts
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo "/usr/share/fonts/nerd-fonts/FiraCode.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip && \
    unzip /usr/share/fonts/nerd-fonts/FiraCode.zip -d /usr/share/fonts/nerd-fonts && \
    rm /usr/share/fonts/nerd-fonts/FiraCode.zip && \
    fc-cache -fv

# Install Poetry
RUN pip install poetry==1.4.2

# Create user and group
RUN addgroup -g 568 iceberg && \
    adduser -u 568 -G iceberg -h /config -s /usr/bin/fish -D iceberg

# Create fish config directory
RUN mkdir -p /home/iceberg/.config/fish

# Expose ports
EXPOSE 3000 8080 5572

# Set environment variable to force color output
ENV FORCE_COLOR=1
ENV TERM=xterm-256color

# Set working directory
WORKDIR /iceberg

# Copy the virtual environment from the builder stage
COPY --from=builder /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy the rest of the application code
COPY --from=cloner /source/backend/ /iceberg/backend
COPY --from=cloner /source/pyproject.toml /source/poetry.lock /iceberg/backend/
COPY --from=cloner /source/VERSION /source/entrypoint.sh /iceberg/

# Copy frontend build from the previous stage
COPY --from=frontend --chown=iceberg:iceberg /app/build /iceberg/frontend/build
COPY --from=frontend --chown=iceberg:iceberg /app/node_modules /iceberg/frontend/node_modules
COPY --from=frontend --chown=iceberg:iceberg /app/package.json /iceberg/frontend/package.json

# Set correct permissions for the iceberg user
RUN chown -R iceberg:iceberg /home/iceberg/.config /iceberg

# Add the components for tmux-in-wetty
COPY apps/riven/riven.sh /iceberg/
COPY apps/riven/launch-tmux.sh /iceberg/
COPY apps/riven/entrypoint.sh /iceberg/
COPY apps/riven/restricted.tmux.conf /usr/src/app

# Ensure entrypoint script is executable
RUN chmod +x /iceberg/entrypoint.sh

# Switch to fish shell
# SHELL ["fish", "--login"]

ENTRYPOINT ["/iceberg/entrypoint.sh"]