FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:2ba3258c7cc40330bfea13a600ca6762591d677db211a3255fbf44d4635481f0 

# set version label
ARG BUILD_DATE
ARG VERSION
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gnupg && \
  echo "**** install resilio-sync ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET http://linux-packages.resilio.com/resilio-sync/deb/dists/resilio-sync/non-free/binary-amd64/Packages |grep -A 7 -m 1 'Package: resilio-sync' | awk -F ': ' '/Version/{print $2;exit}'); \
  fi && \
  echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | tee /etc/apt/sources.list.d/resilio-sync.list && \
  curl -L https://linux-packages.resilio.com/resilio-sync/key.asc | apt-key add && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    "resilio-sync=${VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# ports and volumes
EXPOSE 8888 55555

VOLUME /config /sync

USER 568
COPY ./apps/resilio-sync/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]