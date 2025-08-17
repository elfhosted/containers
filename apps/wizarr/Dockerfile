# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/wizarrrr/wizarr.git /source

# Start from the official Python 3.12 Alpine image
# ─── Stage 1: Dependencies ───────────────────────────────────────────────
FROM ghcr.io/astral-sh/uv:python3.13-alpine AS deps

# Install system dependencies
RUN apk add --no-cache nodejs npm

# Set working directory
WORKDIR /app

# Enable bytecode compilation for faster startup
ENV UV_COMPILE_BYTECODE=1

# Use copy link mode to avoid warnings with cache mounts
ENV UV_LINK_MODE=copy

# Copy dependency files first for better caching
COPY --from=cloner /source/pyproject.toml /source/uv.lock ./

# Install Python dependencies only (not project) with cache mount for speed
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

# Copy npm dependency files and install with cache
COPY --from=cloner /source/app/static/package*.json ./app/static/
RUN npm --prefix app/static/ ci --cache /tmp/npm-cache

# ─── Stage 2: Build assets ────────────────────────────────────────────────
FROM deps AS builder

# Copy source files needed for building
COPY --from=cloner /source/app/ ./app/
COPY --from=cloner /source/babel.cfg ./

# Install the project now that we have source code
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# Build translations
RUN uv run pybabel compile -d app/translations

# Ensure static directories exist and build static assets
RUN mkdir -p app/static/js app/static/css && npm --prefix app/static/ run build

# ─── Stage 3: Runtime ─────────────────────────────────────────────────────
FROM python:3.13-alpine

# Set default environment variables for user/group IDs
ENV PUID=568
ENV PGID=568

# Install runtime dependencies only
RUN apk add --no-cache curl tzdata su-exec

# Set application working directory
WORKDIR /app

# Copy Python environment from builder stage (includes project)
COPY --from=builder /app/.venv /app/.venv

# Make sure we can run uv in the final image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy application code and built assets
COPY --chown=568:568 --from=builder /app/app /app/app
COPY --chown=568:568 . /app

# Create data directory for database (backward compatibility)
RUN mkdir -p /data/database

# Create wizard steps config directory
RUN mkdir -p /etc/wizarr/wizard_steps && \
    chown -R 568:568 /etc/wizarr

# Create directories that need to be writable
RUN mkdir -p /.cache

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

# Healthcheck: curl to localhost:5690/health
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fs http://localhost:5690/health || exit 1

# Expose port 5690
EXPOSE 5690

COPY --from=cloner /source/wizard_steps /opt/default_wizard_steps

# Copy entrypoint script and make it executable
COPY --from=cloner /source/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Entrypoint and default CMD
ENTRYPOINT ["docker-entrypoint.sh"]

# By default we run Gunicorn under wizarruser
CMD ["uv", "run", "gunicorn", \
     "--config", "gunicorn.conf.py", \
     "--bind", "0.0.0.0:5690", \
     "--umask", "007", \
     "run:app"]