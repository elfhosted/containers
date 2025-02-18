ARG VERSION

# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b v$VERSION  https://github.com/bluesky-social/pds.git /source

FROM ghcr.io/bluesky-social/pds:${VERSION} 

ENV S6_OVERLAY_VERSION=3.2.0.2

# Add necessities for ttyd
RUN apk add --no-cache \
    ttyd \
    tmux \
    fish \
    bash \
    openssl \
    curl \
    jq

# Create user and group
RUN addgroup -g 568 elfie && \
adduser -u 568 -G elfie -h /pds -D elfie

# Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN chown -R elfie:elfie /run

COPY apps/bluesky-pds/root /

# Copy pdsadmin commands
COPY --from=cloner --chmod=755 /source/pdsadmin /pdsadmin

# This is our slightly-hacked version
RUN chmod 755 /usr/local/bin/pdsadmin

ENV PDS_DATA_DIRECTORY=/config \
    PDS_BLOBSTORE_DISK_LOCATION=/config/storage \
    PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=bb1ed941a5a004f007441bd5bb297002f4e533fadba48e429f8350249315cf0c \
    PDS_JWT_SECRET=iamsecretforgoss \
    PDS_ADMIN_PASSWORD=yesforgoss \
    PDS_HOSTNAME=nothing.else.com \
    PDS_ADMIN_EMAIL="harry@potter.com" \
    PDS_DID_PLC_URL="https://plc.directory" \
    PDS_BSKY_APP_VIEW_URL="https://api.bsky.app" \
    PDS_BSKY_APP_VIEW_DID="did:web:api.bsky.app" \
    PDS_REPORT_SERVICE_URL="https://mod.bsky.app" \
    PDS_REPORT_SERVICE_DID="did:plc:ar7c4by46qjdydhdevvrndac" \
    PDS_CRAWLERS="https://bsky.network"    

USER 568

WORKDIR /config
# Run the application via s6
ENTRYPOINT [ "/init" ]