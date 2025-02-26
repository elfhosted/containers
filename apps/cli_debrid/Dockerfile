# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/godver3/cli_debrid.git /source

# Add latest cynesync
RUN git clone https://github.com/sureshfizzy/CineSync.git /cinesync

# Use Python 3 as the base image
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends xz-utils

# Define build arguments
ARG RCLONE_VERSION=current

ENV S6_OVERLAY_VERSION=3.2.0.0

# Define working directory.
WORKDIR /tmp

ARG user=elfie
RUN groupadd -g 568 $user && useradd --create-home --uid 568 --gid 568 --shell /bin/bash $user

# Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN chown -R elfie:elfie /run


# Set the working directory in the container
WORKDIR /app

# Install build dependencies and supervisor
RUN apt-get update && apt-get install -y gcc supervisor ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Copy only the requirements file first to leverage Docker cache
COPY --from=cloner /source/requirements-linux.txt .

# Copy cinesync
COPY --from=cloner /cinesync /cinesync

# Install the requirements
RUN pip install --no-cache-dir -r requirements-linux.txt

# Copy the current directory contents into the container at /app
COPY --from=cloner /source/. .

# Create necessary directories and files
RUN mkdir -p /user/db_content /user/config /user/logs && \
    touch /user/logs/debug.log /user/logs/info.log /user/logs/queue.log && \
    chown elfie /user -R && \
    chown elfie /app/

# Set the TERM environment variable for proper terminal attachment
ENV TERM=xterm

# Comment out unwanted commands in shell initialization files
RUN sed -i 's/^export LC_ALL=C.UTF-8/# export LC_ALL=C.UTF-8/' /etc/profile && \
    sed -i 's/^clear/# clear/' /etc/profile

COPY --chown=568:568 apps/cli_debrid/root /

USER 568

ENTRYPOINT [ "/init" ]