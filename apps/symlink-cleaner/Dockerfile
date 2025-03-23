# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/bsm-elf/symlink-cleaner.git /source

# Use an official Python runtime as the base image, slim variant for a smaller footprint
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Create a non-root user with UID 568 (matches your setup) and set ownership of /app
# -m creates a home dir, -s sets shell to bash for usability if needed
RUN useradd -u 568 -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Copy the project files into the container
COPY --from=cloner /source/. .

# Install Python dependencies listed in requirements.txt without caching to keep image size down
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000, where Gunicorn will listen (matches bind in symlink_cleaner.py)
EXPOSE 5000

# Switch to the non-root user for security, ensuring the app runs as appuser (UID 568)
USER appuser

# Run symlink_cleaner.py with the full Python path; Gunicorn is managed programmatically in the script
CMD ["/usr/local/bin/python", "symlink_cleaner.py"]