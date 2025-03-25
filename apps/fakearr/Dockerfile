# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/fakearr.git /source

# Use the official Go image as the base image
FROM golang:1.20-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY --from=cloner /source/go.mod /source/go.sum* ./

# Download dependencies
RUN go mod download

# Copy the source code into the container
COPY /source/. .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o fakearr

# Use a slim alpine image for the final container
FROM alpine:latest

# Install ca-certificates in case we need HTTPS
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /root/

# Copy the pre-built binary from the builder stage
COPY --from=builder /app/fakearr .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the executable
ENTRYPOINT ["./fakearr"]