# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/TheRaceDirector/formuliodev.git /source

FROM python:3.10.12

# Add a non-root user
RUN groupadd -r appuser && useradd -r -g appuser -s /bin/bash -d /home/appuser appuser

# Set the working directory to /tmp/app
WORKDIR /tmp/app

# Copy requirements.txt first for Docker cache optimization
COPY --from=cloner /source/requirements.txt ./

# Install necessary packages
RUN apt-get update && \
    apt-get install -y build-essential libboost-system-dev libboost-python-dev libssl-dev libtorrent-rasterbar-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy the rest of the application code
COPY --from=cloner /source/. .

# Make the /tmp/app directory writable by all users
RUN chmod -R 777 /tmp/app

# Make all 0run_scripts.py scripts and their dependencies executable
RUN find . -name "0run_scripts.py" -exec chmod +x {} + && \
    find . -name "*.py" -exec chmod +x {} +

# Switch to the non-root user
USER appuser

# Command to run the application
CMD ["python3", "formulio-addon.py"]