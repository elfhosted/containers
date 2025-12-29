# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/aymene69/frenchio /source

# Frenchio - Stremio Addon
# Multi-tracker search addon with debrid and qBittorrent support

FROM python:3.11-slim

# Proxy configuration for build time
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ARG http_proxy
ARG https_proxy
ARG no_proxy

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY --from=cloner /source/requirements.txt .

# Install Python dependencies (with proxy support)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --from=cloner /source .

# Expose port
EXPOSE 7777

# Run the application
CMD ["python", "main.py"]
