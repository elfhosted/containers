FROM ghcr.io/elfhosted/ubuntu:focal-20250404@sha256:2ba3258c7cc40330bfea13a600ca6762591d677db211a3255fbf44d4635481f0

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL
ENV S6_OVERLAY_VERSION=3.2.0.0

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_USER="kah" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (geek-cookbook)"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
    apt-get -qq update \
    && \
    apt-get -qq install -y \
        gnupg2 python3 xz-utils \
    && \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            curl -sL https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
            && echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel.list \
            && \
            export ARCH='amd64'; \
            export EXTRA_INSTALL_ARG='intel-opencl-icd=21.49.21786+i643~u20.04'; \
        ;; \
        'linux/arm64') \
            export ARCH='arm64'; \
            export EXTRA_INSTALL_ARG=''; \
        ;; \
    esac \
    && \
    apt-get -qq update \
    && \
    apt-get -qq install -y \
        aria2 \
        uuid-runtime \
        xmlstarlet \
        ca-certificates \
        pulseaudio \
        ${EXTRA_INSTALL_ARG} \
    && \
    echo "Using curl or wget to download the plex debian package result in a qemu failure, why? I dunno" \
    && \
    aria2c -d /tmp -o plex.deb \
        "${PLEX_DOWNLOAD}/${VERSION}/debian/plexmediaserver_${VERSION}_${ARCH}.deb" \
    && \
    dpkg -i --force-confold /tmp/plex.deb \
    && \
    apt-get remove -y aria2 gnupg2 \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && \
    rm -rf \
        /etc/default/plexmediaserver \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/ \
    && chown -R root:root /app \
    && chmod -R 755 "${PLEX_MEDIA_SERVER_HOME}" \
    && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc

WORKDIR "${PLEX_MEDIA_SERVER_HOME}"

ADD https://raw.githubusercontent.com/ChuckPa/PlexDBRepair/master/DBRepair.sh /usr/local/bin/
RUN sed -i "s/RootRequired=1/RootRequired=0/g" /usr/local/bin/DBRepair.sh && \
    chmod 755 /usr/local/bin/DBRepair.sh

# Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN chown -R elfie:elfie /run

COPY --chown=568:568 apps/plex/root /

# install dependencies for vaapi
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        intel-media-va-driver-non-free \
        vainfo \
        i965-va-driver-shaders \
    && rm -rf /var/lib/apt/lists/*

# Prepare fake analysis script
RUN mv "/usr/lib/plexmediaserver/Plex Media Scanner" "/usr/lib/plexmediaserver/Plex Media Scanner.real"
COPY ./apps/plex/fake-scanner.sh /usr/lib/plexmediaserver/
RUN mv /usr/lib/plexmediaserver/fake-scanner.sh "/usr/lib/plexmediaserver/Plex Media Scanner" && \
    chmod +x /usr/lib/plexmediaserver/Plex\ Media\ Scanner
    
USER 568
COPY ./apps/plex/plex-preferences.sh /scripts/plex-preferences.sh
COPY ./apps/plex/entrypoint.sh /entrypoint.sh
COPY ./apps/plex/transcode-killer.py /transcode-killer.py


ENTRYPOINT [ "/init" ]
