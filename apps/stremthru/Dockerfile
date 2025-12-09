# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/MunifTanjim/stremthru.git /source

FROM node:24-alpine AS node-builder

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /workspace

COPY --from=cloner /source/package.json /source/pnpm-lock.yaml /source/pnpm-workspace.yaml ./
COPY --from=cloner /source/apps/dash/package.json ./apps/dash/

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY --from=cloner /source/apps ./apps

RUN pnpm run -r build

FROM golang:1.25 AS builder

WORKDIR /workspace

COPY --from=cloner /source/go.mod /source/go.sum ./
RUN go mod download

COPY --from=cloner /source/migrations ./migrations
COPY --from=cloner /source/core ./core
COPY --from=cloner /source/internal ./internal
COPY --from=cloner /source/store ./store
COPY --from=cloner /source/stremio ./stremio
COPY --from=cloner /source/*.go ./

COPY --from=node-builder /workspace/apps/dash/.output/public/ ./internal/dash/fs/

RUN CGO_ENABLED=1 GOOS=linux go build --tags 'fts5' -o ./stremthru -a -ldflags '-linkmode external -extldflags "-static"'

FROM alpine

RUN apk add --no-cache git

WORKDIR /app

COPY --from=builder /workspace/stremthru ./stremthru

VOLUME ["/app/data"]

ENV STREMTHRU_ENV=prod

EXPOSE 8080

ENTRYPOINT ["./stremthru"]
