FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine318
RUN apk add --update --no-cache python3 git xfce4-terminal && \
    python3 -m ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools && \
    git clone https://github.com/itsToggle/plex_debrid && \
    pip3 install -r ./plex_debrid/requirements.txt

RUN addgroup -S elfie --gid 568 \
        && adduser -S elfie -G elfie --uid 568 && \
        mkdir /elfhosted-config

ENV PUID=568 PGID=568 \
  HOME="/tmp" \
  TITLE="Plex-Debrid | ElfHosted" \
  QTWEBENGINE_DISABLE_SANDBOX="1"

COPY apps/plex-debrid/root /
