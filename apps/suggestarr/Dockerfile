# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/giuseppe99barchetta/SuggestArr /source

# Stage 1: Build the client
FROM node:22 AS client-builder
WORKDIR /app/client
COPY --from=cloner /source/client/package*.json ./
RUN npm install
COPY --from=cloner /source/client/ .
RUN npm run build

# Stage 2: Create the final image
FROM python:3.13-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y curl cron supervisor && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the api_service
WORKDIR /app/api_service

# Copy and install Python dependencies
COPY --from=cloner /source/api_service/requirements.txt /app/api_service/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the client build files from the previous stage
COPY --from=client-builder /app/client/dist /app/static

# Copy the api_service source code
COPY --from=cloner /source/api_service/ /app/api_service/

# Copy Supervisor configuration
COPY apps/suggestarr/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /config --create-home --uid 568 --gid 568 --shell /bin/bash $user && \
    chown elfie /app -R

# Add and configure the cron job
RUN echo "0 0 * * * curl -X POST http://localhost:5000/api/automation/force_run >> /var/log/cron.log 2>&1" > /etc/cron.d/automation-cron && \
    chmod 0644 /etc/cron.d/automation-cron && \
    chown 568  /etc/cron.d/automation-cron && \
    crontab /etc/cron.d/automation-cron

# Create log files for cron and Gunicorn
RUN touch /var/log/cron.log /var/log/gunicorn.log /var/log/gunicorn_error.log

# Expose the port used by Gunicorn
EXPOSE 5000

# Start Supervisor to manage Gunicorn and cron
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]