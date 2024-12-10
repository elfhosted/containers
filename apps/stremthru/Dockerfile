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
COPY --from=cloner /source/schema.hcl source/schema.postgres.hcl ./

RUN mkdir -p /schema
RUN CGO_ENABLED=1 GOOS=linux go build -tags 'heavy' -o ./stremthru -a -ldflags '-linkmode external -extldflags "-static"'


FROM scratch

WORKDIR /app

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /workspace/stremthru ./stremthru

COPY --from=builder /schema /tmp
COPY --from=arigaio/atlas:0.29.0-community /atlas /usr/local/bin/atlas


EXPOSE 8080

ENTRYPOINT ["./stremthru"]