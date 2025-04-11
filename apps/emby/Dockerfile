FROM ghcr.io/elfhosted/ubuntu:focal-20250404@sha256:ff81e19bb95c489d057fd02de96d0a37f6f3006a27d4446aba9306bc70b17c00

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /tmp

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            export ARCH='x86_64'; \
        ;; \
        'linux/arm64') \
            export ARCH='aarch64'; \
        ;; \
    esac \
    && \
    apt-get update -qq \
    && \
    apt-get install -qqy cpio rpm2cpio \
    && \
    mkdir -p /app/emby \
    && \
    curl -fsSL -o emby.rpm \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm" \
    && \
    rpm2cpio emby.rpm | cpio -i --make-directories \
    && \
    mv -t \
        /app/emby \
        /tmp/opt/emby-server/system/* \
        /tmp/opt/emby-server/lib/* \
        /tmp/opt/emby-server/bin/ff* \
        /tmp/opt/emby-server/etc \
        /tmp/opt/emby-server/extra/lib/*

FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:c237763fb7cc7deb53d9484a5941634fbf56a8ed2597bcc3786e875de4c9da6a

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            export EXTRA_INSTALL_ARG='intel-media-va-driver-non-free nvidia-opencl-icd-340 i965-va-driver mesa-va-drivers'; \            
        ;; \
        'linux/arm64') \
            curl -s "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x6587ffd6536b8826e88a62547876ae518cbcf2f2" | apt-key add - \
            && echo "deb http://ppa.launchpad.net/ubuntu-raspi2/ppa-nightly/ubuntu focal main">> /etc/apt/sources.list.d/raspbins.list \
            && \
            export EXTRA_INSTALL_ARG='libomxil-bellagio0 libomxil-bellagio-bin libraspberrypi0'; \
            unset NVIDIA_DRIVER_CAPABILITIES; \
        ;; \
    esac \
    && \
    apt-get update -qq && \
    apt-get install -qqy ${EXTRA_INSTALL_ARG} \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/ \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc

USER 568
COPY --from=builder /app/emby /app/emby
COPY ./apps/emby/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
