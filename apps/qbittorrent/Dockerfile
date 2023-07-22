FROM ghcr.io/geek-cookbook/alpine:edge@sha256:715f0af30346a5bac23f02cba864484d9ad5ce9432dd742a6e9aa284afc76c54

# environment settings
ARG UNRAR_VERSION=6.2.8
ARG VERSION
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base && \
  echo "**** install packages ****" && \
  apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    icu-libs \
    libstdc++ \
    openssl \
    openssl1.1-compat \
    p7zip \
    python3 \
    qt6-qtbase-sqlite && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  install -v -m755 unrar /usr/bin && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    qbittorrent-nox~=${VERSION} && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

WORKDIR /tmp
RUN wget --progress=dot:giga \
        "https://github.com/WDaan/VueTorrent/releases/latest/download/vuetorrent.zip" \
        -O /tmp/vuetorrent.zip && \
    unzip \
        /tmp/vuetorrent.zip && \
        mv /tmp/vuetorrent /vuetorrent

COPY ./apps/qbittorrent/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]