# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b dev  https://github.com/ManiMatter/decluttarr.git /source

FROM python:3.10.13-slim
                                                      
ENV IS_IN_DOCKER 1

WORKDIR /app

COPY --from=cloner /source/docker/requirements.txt ./docker/requirements.txt
RUN pip install --no-cache-dir -r docker/requirements.txt
COPY --from=cloner /source/. .

RUN apt-get -y install tmux dialog

COPY --from=cloner /source/. /
VOLUME /config

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
# add local files
# Add the components for tmux-in-wetty
COPY --chown=568:568 apps/decluttarr/decluttarr.sh /
COPY --chown=568:568 apps/decluttarr/launch-tmux.sh /
COPY --chown=568:568 apps/decluttarr/entrypoint.sh /
COPY --chown=568:568 apps/decluttarr/restricted.tmux.conf /

# ports and volumes


ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /config --create-home --uid 568 --gid 568 --shell /bin/bash $user
RUN chown elfie /config
USER 568

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]