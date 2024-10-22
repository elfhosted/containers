# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/tgdrive/rdebrid-ui.git /source

FROM node:alpine AS builder
RUN apk add --no-cache ca-certificates && update-ca-certificates
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY --from=cloner /source/. /app
WORKDIR /app
RUN pnpm install --frozen-lockfile
RUN pnpm run build:client
RUN pnpm run build:server

FROM denoland/deno:distroless
WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
CMD [ "run","--allow-all","build/server/index.js" ]