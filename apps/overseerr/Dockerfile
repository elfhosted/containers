ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:d143aa2ae054d1061cb6abc8a820506c90330e51fcc95dc7b7f4d2462b61ed3a 

# set environment variables
ENV HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    curl \
    g++ \
    make \
    python3 && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    yarn && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/sct/overseerr/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  export COMMIT_TAG="${VERSION}" && \
  curl -o \
    /tmp/overseerr.tar.gz -L \
    "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" && \
  mkdir -p /app/overseerr && \
  tar xzf \
    /tmp/overseerr.tar.gz -C \
    /app/overseerr/ --strip-components=1 && \
  cd /app/overseerr && \
  export NODE_OPTIONS=--max_old_space_size=2048 && \
  CYPRESS_INSTALL_BINARY=0 yarn --frozen-lockfile --network-timeout 1000000 && \
  yarn build && \
  yarn install --production --ignore-scripts --prefer-offline && \
  yarn cache clean && \
  rm -rf \
    /app/overseerr/src \
    /app/overseerr/server && \
  echo "{\"commitTag\": \"${COMMIT_TAG}\"}" > committag.json && \
  rm -rf /app/overseerr/config && \
  ln -s /config /app/overseerr/config && \
  touch /config/DOCKER && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/* \
    /app/overseerr/.next/cache/*

COPY ./apps/overseerr/entrypoint.sh /

# ports and volumes
EXPOSE 5055
VOLUME /config
USER 568
CMD ["/entrypoint.sh"]
