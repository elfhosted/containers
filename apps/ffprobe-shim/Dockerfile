# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/ffprobe-shim.git /source

# Use the official Golang image to build the binary
FROM golang:1.20 as builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY --from=cloner /source/go.mod /source/go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY --from=cloner /source/. .

# Build the Go binary
RUN go build -o ffprobe-shim ./cmd/ffprobe-shim

# Use a minimal base image to run the binary
FROM debian:bullseye-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/ffprobe-shim .

# Expose the binary as the entrypoint
ENTRYPOINT ["./ffprobe-shim"]