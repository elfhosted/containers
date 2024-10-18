ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:0782c9e41d6e1efe014e1081a12f9f25665aa9b18372de4bd9bb848ace53cceb 

# environment settings
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

USER root

RUN \
  echo "**** install packages ****" && \
  apk --no-cache add \
    icu-data-full \
    icu-libs && \
  echo "**** install jackett ****" && \
  mkdir -p \
    /app/Jackett && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  curl -o \
    /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${VERSION}/Jackett.Binaries.LinuxMuslAMDx64.tar.gz" && \
  tar xf \
    /tmp/jacket.tar.gz -C \
    /app/Jackett --strip-components=1 && \
  echo "**** fix for host id mapping error ****" && \
  chown -R root:root /app/Jackett && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# ports and volumes
VOLUME /config
EXPOSE 9117

USER 568

CMD ["/app/Jackett/jackett", "--NoUpdates"]
