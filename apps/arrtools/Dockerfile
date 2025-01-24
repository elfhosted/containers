# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/sirk123au/ArrTools.git /source

# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y inotify-tools tmux bash dialog fish && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file and install dependencies (note upstream typo)
COPY --from=cloner /source/requirments.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project to the container's working directory
COPY --from=cloner --chmod=755 /source/*.py /app

# Set PYTHONPATH to include the MediaHub directory
ENV PYTHONPATH=/usr/local/bin

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
# add local files
COPY --chown=568:568 apps/arrtools/arrtools.sh /
COPY --chown=568:568 apps/arrtools/launch-tmux.sh /
COPY --chown=568:568 apps/arrtools/entrypoint.sh /
COPY --chown=568:568 apps/arrtools/restricted.tmux.conf /

# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /config --create-home --uid 568 --gid 568 --shell /bin/bash $user
USER 568

# Run the application
ENTRYPOINT ["/entrypoint.sh"]