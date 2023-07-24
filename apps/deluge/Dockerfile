FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:afb00cc50357341fb591a9940889c31e330d9a2e7f4a7d7cb77ef24f00cc423b

ARG UNRAR_VERSION=6.1.7
# set version label
ARG BUILD_DATE
ARG VERSION

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# install software
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    make \
    g++ \
    gcc \
    curl \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache --upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    python3 \
    py3-geoip \
    p7zip && \
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
  install -v -m755 unrar /usr/local/bin && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:deluge$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    deluge~=${VERSION} && \  
  echo "**** install python packages ****" && \
  python3 -m ensurepip && \
  pip3 install -U --no-cache-dir \
    pip \
    wheel && \
  pip3 install --no-cache-dir \
    future \
    requests && \
  echo "**** grab GeoIP database ****" && \
  curl -o \
    /usr/share/GeoIP/GeoIP.dat -L --retry 10 --retry-max-time 60 --retry-all-errors \
    "https://infura-ipfs.io/ipfs/QmWTWcPRRbADZcLcJeANZmcJZNrcpmuQgKYBi6hGdddtC6" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

COPY ./apps/deluge/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]