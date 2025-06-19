
# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b ${VERSION}  https://github.com/chocobozzz/peertube.git /source

FROM node:20-bookworm-slim

ARG ALREADY_BUILT=0

# Install dependencies
RUN apt update \
 && apt install -y --no-install-recommends openssl ffmpeg python3 python3-pip ca-certificates gnupg gosu build-essential curl git \
 && gosu nobody true \
 && rm /var/lib/apt/lists/* -fR

# Node images hardcode the node uid to 1000 so that number is not available.
# The "peertube" user is created as a system account which selects a UID from
# the range of SYS_UID_MIN to SYS_UID_MAX (-1 to 1000] and consistently
# selects 999 given the current image build steps. The same is true for the
# system group range SYS_GID_MIN and SYS_GID_MAX. It is fine to manually assign
# them an ID outside of that range.
ENV DEFAULT_PEERTUBE_UID=568
ENV DEFAULT_PEERTUBE_GID=568

# Add peertube user
RUN groupadd -r -g ${PEERTUBE_GID:-${DEFAULT_PEERTUBE_GID}} peertube \
    && useradd -r -u ${PEERTUBE_UID:-${DEFAULT_PEERTUBE_UID}} -g peertube -m peertube

# Install PeerTube
COPY --chown=peertube:peertube --from=cloner /source/. /app
WORKDIR /app

USER peertube

# Install manually client dependencies to apply our network timeout option
RUN if [ "${ALREADY_BUILT}" = 0 ]; then \
    npm run install-node-dependencies -- --network-timeout 1200000 \
    && npm run build; \
  else \
    echo "Do not build application inside Docker because of ALREADY_BUILT build argument"; \
  fi; \
  rm -rf ./node_modules ./client/node_modules ./client/.angular \
  && NOCLIENT=1 npm run install-node-dependencies -- --production --network-timeout 1200000 --network-concurrency 20 \
  && yarn cache clean

USER root

RUN mkdir /data /config
RUN chown -R peertube:peertube /data /config

ENV NODE_ENV production
ENV NODE_CONFIG_DIR /app/config:/app/support/docker/production/config:/config
ENV PEERTUBE_LOCAL_CONFIG /config

VOLUME /data
VOLUME /config

COPY --from=cloner /source/support/docker/production/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]


# install dependencies for vaapi
RUN 	   apt update \
	&& apt install -y --no-install-recommends wget apt-transport-https \
	&& echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian/ $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) non-free" | tee /etc/apt/sources.list.d/non-free.list \
	&& echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian/ $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) non-free-firmware" | tee /etc/apt/sources.list.d/non-free-firmware.list \
    && apt update \
	&& apt install -y --no-install-recommends intel-media-va-driver-non-free vainfo i965-va-driver-shaders \
	&& rm /var/lib/apt/lists/* -fR

# Run the application
CMD [ "node", "dist/server" ]
