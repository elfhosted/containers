# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG CACHE_BUST=1

RUN apk update && apk upgrade && \
    apk add --no-cache git && \
    echo "cache bust: ${CACHE_BUST}"

RUN git clone -b $VERSION https://github.com/TimilsinaBimal/Watchly.git /source

# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY --from=cloner /source/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code (including static files)
COPY --from=cloner /source/app/ ./app/
COPY --from=cloner /source/static/ ./static/
COPY --from=cloner /source/main.py .
COPY --from=cloner /source/pyproject.toml .

ENTRYPOINT ["python", "main.py"]