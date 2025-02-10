# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# for now, just clone latest
RUN git clone https://github.com/sureshfizzy/CineSync.git /source

# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y inotify-tools tmux bash dialog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file and install dependencies
COPY --from=cloner /source/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project to the container's working directory
COPY --from=cloner /source/MediaHub /app/MediaHub
COPY --from=cloner /source/.env ./

# Set PYTHONPATH to include the MediaHub directory
ENV PYTHONPATH=/app/MediaHub

# Set environment variables from the .env file
RUN export $(grep -v '^#' .env | xargs -d '\n' -I {} echo "ENV {}")

# fix for goss, will be overridden in chart
ENV DESTINATION_DIR=/tmp
ENV SOURCE_DIR=/tmp

# Create necessary directories
RUN mkdir -p /app/db

# Set environment variables for PUID and PGID
ENV PUID=1000
ENV PGID=1000

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
# add local files
COPY --chown=568:568 apps/cinesync/cinesync.sh /
COPY --chown=568:568 apps/cinesync/launch-tmux.sh /
COPY --chown=568:568 apps/cinesync/entrypoint.sh /
COPY --chown=568:568 apps/cinesync/restricted.tmux.conf /

# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /app/db --create-home --uid 568 --gid 568 --shell /bin/bash $user
RUN chown elfie /app/db
USER 568

# Run the application
ENTRYPOINT ["/entrypoint.sh"]