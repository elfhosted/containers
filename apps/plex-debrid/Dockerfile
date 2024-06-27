FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/butlerx/wetty.git /source

# Get plex_debrid source
RUN git clone --depth 1 https://github.com/itsToggle/plex_debrid /plex_debrid


FROM python:3.11-alpine

# LABEL maintainer="butlerx@notthe.cloud"
# WORKDIR /usr/src/app
# ENV NODE_ENV=production
# EXPOSE 3000

# ENV PNPM_HOME="/pnpm"
# ENV PATH="$PNPM_HOME:$PATH"
# RUN corepack enable
# RUN npx pnpm i -g pnpm@v8


# COPY --from=prod-deps /usr/src/app/node_modules /usr/src/app/node_modules
# COPY --from=build /usr/src/app/build /usr/src/app/build
COPY --from=cloner /plex_debrid /usr/src/app/plex_debrid
COPY --from=cloner /source/package.json /usr/src/app
# RUN apk add -U coreutils

RUN apk add --update --no-cache py3-pip tmux ttdy && \
    python3 -m venv plex_debrid/.venv && \
    . plex_debrid/.venv/bin/activate && \
    pip3 install --break-system-packages --no-cache --upgrade pip setuptools && \
    pip3 install -r ./plex_debrid/requirements.txt

COPY apps/plex-debrid/plex-debrid.sh /
COPY apps/plex-debrid/launch-tmux.sh /
COPY apps/plex-debrid/entrypoint.sh /
COPY apps/plex-debrid/restricted.tmux.conf /usr/src/app

# Apply the trakt fix
COPY apps/plex-debrid/trakt.py /usr/src/app/plex_debrid/content/services/

ENTRYPOINT [ "/entrypoint.sh" ]




# FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine318


# # We'll mount this for storing settings.json
# RUN mkdir -p /config/elfhosted

# ENV TITLE="Plex-Debrid | ElfHosted" \
#   QTWEBENGINE_DISABLE_SANDBOX="1"




