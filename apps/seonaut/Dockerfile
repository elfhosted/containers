# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/StJudeWasHere/seonaut.git /source

FROM golang:1.22-alpine3.18 AS builder

RUN mkdir /app
COPY --from=cloner /source/. /app
WORKDIR /app

RUN CGO_ENABLED=0 GOOS=linux go build -o seonaut cmd/server/main.go

FROM node:18-alpine3.18 AS front
WORKDIR /home/node
COPY --from=builder /app ./app/
RUN npm install --save-exact esbuild && ./node_modules/esbuild/bin/esbuild ./app/web/css/style.css \
	--bundle \
	--minify \
	--outdir=./app/web/static \
	--public-path=/resources \
	--loader:.woff=file \
	--loader:.woff2=file

FROM alpine:latest AS production
COPY --from=front /home/node/app /app/

ENV WAIT_VERSION 2.9.0
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /bin/wait
RUN chmod +x /bin/wait

WORKDIR /app

