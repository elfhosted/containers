# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/MunifTanjim/stremthru.git /source

FROM golang:1.23 AS builder

WORKDIR /workspace

COPY --from=cloner /source/go.mod /source/go.sum ./
RUN go mod download

COPY --from=cloner /source/core ./core
COPY --from=cloner /source/internal ./internal
COPY --from=cloner /source/store ./store
COPY --from=cloner /source/*.go ./

RUN CGO_ENABLED=1 GOOS=linux go build -o ./stremthru -a -ldflags '-linkmode external -extldflags "-static"'

FROM ghcr.io/elfhosted/alpine:rolling@sha256:672b59dc4580b8aaae42e839c878501109ed7a810072c872363250930899bf16 


WORKDIR /app

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /workspace/stremthru ./stremthru

COPY --from=cloner /source/scripts/schema.sh /scripts/
COPY --from=cloner /source/schema.hcl /

EXPOSE 8080

ENTRYPOINT ["./stremthru"]
