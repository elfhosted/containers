# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/rivenmedia/riven.git /source

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
FROM python:3.11-alpine

LABEL name="Iceberg" \
      description="Iceberg Debrid Downloader" \
      url="https://github.com/dreulavelle/riven"


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
    make \
    build-base \
    ttyd \
    git \
    python3-dev && \
    npm install -g pnpm

# Install Nerd Fonts
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo "/usr/share/fonts/nerd-fonts/FiraCode.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip && \
    unzip /usr/share/fonts/nerd-fonts/FiraCode.zip -d /usr/share/fonts/nerd-fonts && \
    rm /usr/share/fonts/nerd-fonts/FiraCode.zip && \
    fc-cache -fv

# Create user and group
RUN addgroup -g 568 elfie && \
adduser -u 568 -G elfie -h /config -D elfie


# Expose ports
EXPOSE 3000 8080 5572

# Set environment variable to force color output
ENV FORCE_COLOR=1
ENV TERM=xterm-256color

# Add the components for tmux-in-wetty
COPY --chown=568:568 apps/riven/riven.sh /riven/
COPY --chown=568:568 apps/riven/launch-tmux.sh /riven/
COPY --chown=568:568 apps/riven/entrypoint.sh /riven/
COPY --chown=568:568 apps/riven/restricted.tmux.conf /riven/
COPY --chown=568:568 --chmod=755 apps/riven/wait-for-it.sh /usr/local/bin/

# # Ensure entrypoint script is executable
RUN chmod +x /riven/entrypoint.sh

USER 568
# Set working directory
WORKDIR /riven

# Copy the rest of the application code
COPY --chown=568:568 --from=cloner /source/backend/ /riven/backend
COPY --chown=568:568 --from=cloner /source/pyproject.toml /source/poetry.lock /riven/backend/
COPY --chown=568:568 --from=cloner /source/VERSION /riven/
COPY --chown=568:568 --from=frontend /app/build /riven/frontend/build
COPY --chown=568:568 --from=frontend /app/node_modules /riven/frontend/node_modules
COPY --chown=568:568 --from=frontend /app/package.json /riven/frontend/package.json


# Copy the virtual environment from the builder stage
COPY --chown=568:568 --from=builder /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Install Poetry
RUN pip install poetry==1.4.2 

# && \
#     poetry install --no-root --without dev

ENTRYPOINT ["/riven/entrypoint.sh"]
