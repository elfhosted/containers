# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Kometa-Team/ImageMaid.git /source

FROM python:3.11-slim-buster
ARG BRANCH_NAME=master
ENV BRANCH_NAME ${BRANCH_NAME}
ENV TINI_VERSION v0.19.0
ENV KOMETA_DOCKER True
COPY --from=cloner /source/requirements.txt requirements.txt
RUN echo "**** install system packages ****" \
 && apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y tzdata --no-install-recommends \
 && apt-get install -y gcc g++ libxml2-dev libxslt-dev libz-dev libjpeg62-turbo-dev zlib1g-dev wget curl \
 && wget -O /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-"$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && chmod +x /tini \
 && pip3 install --no-cache-dir --upgrade --requirement /requirements.txt \
 && apt-get --purge autoremove gcc g++ libxml2-dev libxslt-dev libz-dev -y \
 && apt-get clean \
 && apt-get update \
 && apt-get check \
 && apt-get -f install \
 && apt-get -y install tmux dialog \
 && apt-get autoclean \
 && rm -rf /requirements.txt /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY --from=cloner /source/. /
VOLUME /config

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
# add local files
# Add the components for tmux-in-wetty
COPY --chown=568:568 apps/imagemaid/imagemaid.sh /
COPY --chown=568:568 apps/imagemaid/launch-tmux.sh /
COPY --chown=568:568 apps/imagemaid/entrypoint.sh /
COPY --chown=568:568 apps/imagemaid/restricted.tmux.conf /

# ports and volumes


ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /config --create-home --uid 568 --gid 568 --shell /bin/bash $user
RUN chown elfie /config
USER 568

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]