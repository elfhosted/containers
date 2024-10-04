# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://gitlab.com/book2566/krantorbox.git  /source

FROM golang:1.23-alpine

WORKDIR /app

# Copy go.mod and go.sum files
COPY --from=cloner /source/go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the application's source code
COPY --from=cloner /source/. .

# Build the application
RUN go build -o krantorbox

# Run the application
CMD ["/app/krantorbox"]