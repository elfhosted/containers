ARG VERSION

FROM debian:stable-slim as builder

LABEL org.opencontainers.image.source https://github.com/geek-cookbook/docker-deluge

SHELL ["/bin/bash", "-c"]

ARG VERSION
ARG UNRAR_VERSION=6.1.4
ARG libtorrent_minimum_version=1.2.0
ARG tag=" static with c++14 march=native"
ARG libtorrent_branch=RC_1_2
ARG distver=python3
ARG LT_PATCH=""
ARG BOOST_VERSION=1_75_0
ENV ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3028,DL3009,DL3015
RUN apt-get update && apt-get install build-essential cmake git ninja-build pkg-config libboost-dev libssl-dev zlib1g-dev \
    qtbase5-dev qttools5-dev libqt5svg5-dev wget unzip -y && \
    apt-get autoremove -y && \
    apt-get clean

COPY ./apps/qbittorrent/build.sh /build.sh

WORKDIR /tmp
# hadolint ignore=DL3003
RUN git clone --recurse-submodules --branch ${libtorrent_branch} https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local && \
    cmake --build build && \
    cmake --install build

WORKDIR /tmp/unrar
RUN wget --progress=dot:giga \
        "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" \
        -O /tmp/unrar.tar.gz && \
    tar xf \
        /tmp/unrar.tar.gz -C \
        /tmp/unrar --strip-components=1 && \
    make && \
    install -v -m755 unrar /usr/local/bin

WORKDIR /tmp
# hadolint ignore=DL3003
RUN wget --progress=dot:giga \
        "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-${VERSION}.zip" \
        -O /tmp/qbittorrent.zip && \
    unzip \
        /tmp/qbittorrent.zip && \
    cd /tmp/qBittorrent-release-${VERSION} && \
    cmake -G "Ninja" -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local -DGUI=OFF && \
    cmake --build build

WORKDIR /tmp
RUN wget --progress=dot:giga \
        "https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip" \
        -O /tmp/vuetorrent.zip && \
    unzip \
        /tmp/vuetorrent.zip 

FROM debian:stable-slim
ARG VERSION

# hadolint ignore=DL3008,DL3028,DL3009
RUN apt-get update && apt-get install python3 libqt5network5 libqt5sql5 libqt5xml5 \ 
    dumb-init curl ca-certificates --no-install-recommends xz-utils openjdk-17-jre -y && \
    apt-get autoremove -y && \
    apt-get clean 

RUN curl -o /tmp/filebot.xz -L "https://get.filebot.net/filebot/FileBot_5.0.1/FileBot_5.0.1-portable.tar.xz" && \
    mkdir -p /opt/filebot && \
    tar xvf /tmp/filebot.xz -C /opt/filebot && \
    rm -rf /tmp/filebot.xz && \
    ln -s /opt/filebot/filebot.sh /usr/local/bin/filebot

COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /usr/local/lib/libtorrent-rasterbar.so.10 /usr/local/lib/libtorrent-rasterbar.so.10
COPY --from=builder /tmp/vuetorrent /vuetorrent
COPY --from=builder /tmp/qBittorrent-release-${VERSION}/build/qbittorrent-nox /usr/local/bin/
COPY ./apps/qbittorrent/entrypoint.sh /entrypoint.sh

# USER root 

ENV HOME="/config/qBittorrent/" \
XDG_CONFIG_HOME="/config/qBittorrent/" \
XDG_DATA_HOME="/config/qBittorrent/"
ENTRYPOINT ["/usr/bin/dumb-init","/entrypoint.sh"]