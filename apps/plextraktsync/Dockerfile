FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:2ba3258c7cc40330bfea13a600ca6762591d677db211a3255fbf44d4635481f0 

RUN apt-get -y update && apt-get -y install curl tmux pipx python3.8-venv

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd



COPY --chown=568:568 apps/plextraktsync/plextraktsync.sh /
COPY --chown=568:568 apps/plextraktsync/launch-tmux.sh /
COPY --chown=568:568 apps/plextraktsync/entrypoint.sh /
COPY --chown=568:568 apps/plextraktsync/restricted.tmux.conf /

RUN mkdir -p /home/elfie && chown -R elfie /home/elfie

# Run elfie in rbash
RUN usermod -s /bin/bash elfie

USER 568
# We need plextraktsync
RUN pipx install PlexTraktSync

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]