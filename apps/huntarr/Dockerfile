FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/plexguide/Huntarr.io /source

FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY --from=cloner /source/. /app/

# Create necessary directories
RUN mkdir -p /config/settings /config/stateful /config/user /config/logs
RUN chmod -R 755 /config

# Expose port
EXPOSE 9705

# Run the application
CMD ["python3", "main.py"]