# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/ceresimaging/csi-rclone.git /source

####
FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git make bash
WORKDIR $GOPATH/src/csi-rclone-nodeplugin
COPY --from=cloner /source/. .
RUN make plugin

####
FROM alpine:3.16
RUN apk add --no-cache ca-certificates bash fuse3 curl unzip tini

# To install the latest version when building: v1.68 seems to be broken
# RUN curl https://rclone.org/install.sh | bash

# Hard-coding to the latest 1.67 version
# https://rclone.org/install/#linux
# https://rclone.org/downloads/#older-downloads

ARG RCLONE_VERSION="v1.67.0"
ARG OS="linux"
ARG OS_type="amd64"

# Platform detection copied from https://rclone.org/install.sh
RUN OS="$(uname)" && \
    case $OS in \
      Linux) \
        OS='linux' \
        ;; \
      FreeBSD) \
        OS='freebsd' \
        ;; \
      NetBSD) \
        OS='netbsd' \
        ;; \
      OpenBSD) \
        OS='openbsd' \
        ;; \
      Darwin) \
        OS='osx' \
        ;; \
      SunOS) \
        OS='solaris' \
        echo 'OS not supported' \
        exit 2 \
        ;; \
      *) \
        echo 'OS not supported' \
        exit 2 \
        ;; \
    esac && \
    OS_type="$(uname -m)" && \
    case "$OS_type" in \
      x86_64|amd64) \
        OS_type='amd64' \
        ;; \
      i?86|x86) \
        OS_type='386' \
        ;; \
      aarch64|arm64) \
        OS_type='arm64' \
        ;; \
      armv7*) \
        OS_type='arm-v7' \
        ;; \
      armv6*) \
        OS_type='arm-v6' \
        ;; \
      arm*) \
        OS_type='arm' \
        ;; \
      *) \
        echo 'OS type not supported' \
        exit 2 \
        ;; \
    esac && \
    curl -OfsS "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-${OS}-${OS_type}.zip" && \
    unzip "rclone-${RCLONE_VERSION}-${OS}-${OS_type}.zip" && \
    cd "rclone-${RCLONE_VERSION}-${OS}-${OS_type}" && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

# Use pre-compiled version (with cirectory marker patch)
# https://github.com/rclone/rclone/pull/5323
# COPY bin/rclone /usr/bin/rclone
# RUN chmod 755 /usr/bin/rclone \
#     && chown root:root /usr/bin/rclone

COPY --from=builder /go/src/csi-rclone-nodeplugin/_output/csi-rclone-plugin /bin/csi-rclone-plugin

ENTRYPOINT [ "/sbin/tini", "--"]
CMD ["/bin/csi-rclone-plugin"]