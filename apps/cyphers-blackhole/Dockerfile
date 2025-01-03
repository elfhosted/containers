FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/sirrobot01/debrid-blackhole.git  /source

FROM --platform=$BUILDPLATFORM golang:1.23 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Set destination for COPY
WORKDIR /app

# Download Go modules
COPY --from=cloner /source/. .
RUN go mod download

# Build
RUN CGO_ENABLED=0 GOOS=$(echo $TARGETPLATFORM | cut -d '/' -f1) GOARCH=$(echo $TARGETPLATFORM | cut -d '/' -f2) go build -o /blackhole

EXPOSE 8181

# Run
CMD ["/blackhole", "--config", "/app/config.json"]