FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:c237763fb7cc7deb53d9484a5941634fbf56a8ed2597bcc3786e875de4c9da6a as builder

# set version label
ARG VERSION
ARG NZBHYDRA2_RELEASE=${VERSION}

# environment settings
ENV NZBHYDRA2_RELEASE_TYPE="Release" \
  DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    libfreetype6 \
    python3 \
    unzip && \
  echo "**** install nzbhydra2 ****" && \
  if [ -z ${NZBHYDRA2_RELEASE+x} ]; then \
    NZBHYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  NZBHYDRA2_VER=${NZBHYDRA2_RELEASE#v} && \
  curl -o \
    /tmp/nzbhydra2.zip -L \
    "https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VER}/nzbhydra2-${NZBHYDRA2_VER}-amd64-linux.zip" && \
  mkdir -p /app/nzbhydra2 && \
  unzip /tmp/nzbhydra2.zip -d /app/nzbhydra2 && \
  chmod +x /app/nzbhydra2/nzbhydra2wrapperPy3.py && \
  if [ -f /app/nzbhydra2/core ]; then chmod +x /app/nzbhydra2/core; fi && \
  echo "ReleaseType=${NZBHYDRA2_RELEASE_TYPE}\nPackageVersion=${VERSION}\nPackageAuthor=linuxserver.io" > /app/nzbhydra2/package_info && \
  mkdir -p /defaults && \
  curl -o \
    /defaults/nzbhydra.yml -L \
    "https://raw.githubusercontent.com/theotherp/nzbhydra2/v${NZBHYDRA2_VER}/core/src/main/resources/config/baseConfig.yml" && \
  sed -i 's/mapIpToHost: true/mapIpToHost: false/' /defaults/nzbhydra.yml && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /var/log/* \
    /app/nzbhydra2/upstart \
    /app/nzbhydra2/rc.d \
    /app/nzbhydra2/sysv \
    /app/nzbhydra2/systemd

# ports and volumes
EXPOSE 5076

VOLUME /config # needed for goss tests
USER 568
COPY ./apps/nzbhydra2/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/theotherp/nzbhydra2"
