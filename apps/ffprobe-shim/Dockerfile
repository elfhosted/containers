# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/ffprobe-shim.git /source

FROM golang:1.24-alpine AS builder

# Install git for fetching dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY --from=cloner /source/go.mod go.sum* ./

# Initialize module if go.mod doesn't exist
RUN if [ ! -f go.mod ]; then \
    go mod init ffprobe-shim && \
    go get github.com/middelink/go-parse-torrent-name; \
    else \
    go get github.com/middelink/go-parse-torrent-name; \
    fi

# Copy source code
COPY --from=cloner /source/*.go ./

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o ffprobe

# Create a minimal runtime image
FROM alpine:latest

# Create directory for logs
RUN mkdir -p /tmp

# Copy our compiled binary
COPY --from=builder /app/ffprobe /usr/bin/ffprobe

# Ensure our binary is executable
RUN chmod +x /usr/bin/ffprobe

# Create a non-root user
RUN adduser -D appuser
USER appuser

# Set the entrypoint to run our shim or optionally the real ffprobe
ENTRYPOINT ["/usr/bin/ffprobe"]