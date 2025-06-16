# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/dvcrn/csi-rclone-reloaded.git /source

####
FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git make bash
WORKDIR $GOPATH/src/csi-rclone-nodeplugin
COPY --from=cloner /source/. .
RUN make plugin

####
FROM alpine:3.21

ARG RCLONE_VERSION="v1.69.3"
ARG OS="linux"
ARG OS_type="amd64"

RUN apk add --no-cache ca-certificates bash fuse3 curl unzip tini

RUN curl -OfsS "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-${OS}-${OS_type}.zip" && \
    unzip "rclone-${RCLONE_VERSION}-${OS}-${OS_type}.zip" && \
    cd "rclone-${RCLONE_VERSION}-${OS}-${OS_type}" && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone


COPY --from=builder /go/src/csi-rclone-nodeplugin/_output/csi-rclone-plugin /bin/csi-rclone-plugin

ENTRYPOINT [ "/sbin/tini", "--"]
CMD ["/bin/csi-rclone-plugin"]