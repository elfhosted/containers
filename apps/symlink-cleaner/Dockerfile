# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/bsm-elf/symlink-cleaner.git /source

# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Create a non-root user with UID 568
RUN useradd -u 568 -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Copy the project files into the container
COPY --from=cloner /source/. .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Switch to the non-root user
USER appuser

# Command to run the app with gunicorn and eventlet
CMD ["gunicorn", "--worker-class", "eventlet", "-w", "1", "--bind", "0.0.0.0:5000", "symlink_cleaner:app"]