FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine318
RUN apk add --update --no-cache python3 git && \
    python3 -m ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools && \
    git clone https://github.com/itsToggle/plex_debrid && \
    pip3 install -r ./plex_debrid/requirements.txt

COPY apps/plex_debrid/root /
