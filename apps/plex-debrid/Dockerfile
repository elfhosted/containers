FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# Get plex_debrid source
RUN git clone  https://github.com/elfhosted/plex_debrid /source


FROM python:3.11-alpine

# COPY --from=prod-deps /usr/src/app/node_modules /usr/src/app/node_modules
# COPY --from=build /usr/src/app/build /usr/src/app/build
COPY --from=cloner /source /usr/src/app/
# RUN apk add -U coreutils

WORKDIR /usr/src/app
RUN apk add --update --no-cache py3-pip tmux ttyd  && \
    mkdir /.local && \
    chown 568 /.local

# && \
#     python3 -m venv plex_debrid/.venv && \
#     . plex_debrid/.venv/bin/activate && \

USER 568
RUN pip3 install --break-system-packages --no-cache --upgrade pip setuptools && \
    pip3 install -r ./requirements.txt

COPY apps/plex-debrid/plex-debrid.sh /
COPY apps/plex-debrid/launch-tmux.sh /
COPY apps/plex-debrid/entrypoint.sh /
COPY apps/plex-debrid/restricted.tmux.conf /usr/src/app

# Apply the trakt fix
COPY apps/plex-debrid/trakt.py /usr/src/app/plex_debrid/content/services/

WORKDIR /config
ENTRYPOINT [ "/entrypoint.sh" ]




# FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine318


# # We'll mount this for storing settings.json
# RUN mkdir -p /config/elfhosted

# ENV TITLE="Plex-Debrid | ElfHosted" \
#   QTWEBENGINE_DISABLE_SANDBOX="1"




