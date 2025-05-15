# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/mhdzumair/MediaFusion.git /source

# Add ElfHosted branding
COPY apps/mediafusion/branding/mediafusion-elfhosted-logo.png /source/resources/images/

# Now based on the upstream Dockerfile
FROM python:3.13-slim-bookworm AS builder

WORKDIR /mediafusion

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl build-essential && \
    pip install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the mediafusion user with a specified home directory
RUN groupadd -r mediafusion && \
    useradd --no-log-init -r -g mediafusion -m -d /home/mediafusion mediafusion

RUN chown -R mediafusion:mediafusion /mediafusion
USER mediafusion

# Set the PATH environment variable to include the local bin directory
ENV PATH="/home/mediafusion/.local/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Install uv and Python dependencies
COPY --from=ghcr.io/astral-sh/uv:0.7.4 /uv /uvx /bin/
COPY --chown=mediafusion:mediafusion --from=cloner /source/uv.lock /source/pyproject.toml ./
RUN uv sync --frozen --no-install-project --compile-bytecode

FROM python:3.13-slim-bookworm

ARG VERSION
ENV VERSION=${VERSION}

WORKDIR /mediafusion

# Create the mediafusion user with a specified home directory
RUN groupadd -r mediafusion && \
    useradd --no-log-init -r -g mediafusion -m -d /home/mediafusion mediafusion

# Copy the Python environment and other necessary files from the builder stage
COPY --from=builder --chown=mediafusion:mediafusion /mediafusion/.venv /mediafusion/.venv

ENV PATH="/mediafusion/.venv/bin:$PATH"

COPY --from=cloner --chown=mediafusion:mediafusion /source/. .

USER mediafusion

EXPOSE 8000
EXPOSE 9191

CMD ["gunicorn", "api.main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--timeout", "120", "--max-requests", "2500", "--max-requests-jitter", "500"]
