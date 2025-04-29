# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/MunifTanjim/stremthru.git /source

FROM golang:1.24 AS builder

WORKDIR /workspace

COPY --from=cloner /source/go.mod /source/go.sum ./
RUN go mod download

COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/core ./core
COPY --from=cloner /source/internal ./internal
COPY --from=cloner /source/store ./store
COPY --from=cloner /source/stremio ./stremio
COPY --from=cloner /source/*.go ./

RUN CGO_ENABLED=1 GOOS=linux go build -o ./stremthru -a -ldflags '-linkmode external -extldflags "-static"'

FROM alpine

RUN apk add --no-cache git

WORKDIR /app

COPY --from=builder /workspace/stremthru ./stremthru

VOLUME ["/app/data"]

EXPOSE 8080

ENTRYPOINT ["./stremthru"]
