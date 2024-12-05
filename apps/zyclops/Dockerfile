# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/zyclops.git /source
# Build stage
FROM golang:latest AS builder

WORKDIR /app
COPY --from=cloner /source/. .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o zyclops ./cmd/zyclops

# Final stage
FROM alpine:3.21

WORKDIR /app
COPY --from=builder /app/zyclops .

# Create directory for Bleve index
RUN mkdir -p /data

# Set environment variables
ENV INDEX_PATH=/data/torrents.bleve \
    SERVER_PORT=8080 \
    SERVER_HOST="" \
    SEARCH_ENDPOINT=/dmm/search

EXPOSE 8080

ENTRYPOINT ["/app/zyclops"]