# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/bsm-elf/symlink-cleaner.git /source

# Base image
FROM python:3.9-slim

# Set environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=symlink_cleaner.py \
    FLASK_ENV=production

# Create app directory
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency list and install
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files with correct ownership
COPY --chown=568:568 --from=cloner /source/symlink_cleaner.py /app/
COPY --chown=568:568 --from=cloner /source/templates/ /app/templates/
COPY --chown=568:568 --from=cloner /source/static/ /app/static/
COPY --chown=568:568 --from=cloner /source/config/ /app/config/

# Ensure the entire /app is writable by the runtime user
RUN chown -R 568:568 /app

# Run as non-root user
USER 568

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python", "symlink_cleaner.py"]