# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/TheRaceDirector/formuliodev.git /source

# Add branding
COPY apps/formulio/branding/index.html /source/static/

# Build stage
FROM python:3.10.14-slim-bookworm AS builder

# Set the working directory
WORKDIR /app

# Copy requirements file
COPY --from=cloner /source/requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.10.14-slim-bookworm

# Copy installed packages from builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Add a non-root user
RUN groupadd -r appuser && useradd -r -g appuser -s /bin/bash -d /home/appuser appuser

# Set the working directory
WORKDIR /app

# Copy the application code
COPY --from=cloner /source/. .

# Set the PYTHONPATH
ENV PYTHONPATH=/app

# Make the /app directory writable by all users
RUN chown appuser -R /app

# Create log directory and set permissions
RUN mkdir -p /var/log/gunicorn && chown appuser:appuser /var/log/gunicorn

# Switch to the non-root user
USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

# Command to run the application
CMD ["gunicorn", "-c", "gunicorn_config.py", "formulio_addon:app"]

# Expose port 8000
EXPOSE 8000