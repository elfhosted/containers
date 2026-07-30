# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# elfhosted fork carries mount-hardening patches (dir-cache-time, backend timeouts,
# removed legacy cache flags) on top of dvcrn/csi-rclone-reloaded. See branch.
RUN git clone -b elf-mount-hardening https://github.com/funkypenguin/csi-rclone-reloaded.git /source

####
FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git make bash
WORKDIR $GOPATH/src/csi-rclone-nodeplugin
COPY --from=cloner /source/. .
RUN make plugin

####
FROM alpine:3.21

ARG RCLONE_VERSION="v1.74.4"
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