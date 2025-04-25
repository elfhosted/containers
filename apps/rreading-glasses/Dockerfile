# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/blampe/rreading-glasses.git /source


FROM --platform=$BUILDPLATFORM golang:1.24.2-alpine AS build

WORKDIR /app
COPY --from=cloner /source/go.mod go.sum ./
RUN go mod download
COPY --from=cloner /source/schema.sql .
COPY --from=cloner /source/. .

ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -o /app/main

FROM gcr.io/distroless/static:nonroot AS app
COPY --from=build /app/main /main
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8788
CMD ["/main"]