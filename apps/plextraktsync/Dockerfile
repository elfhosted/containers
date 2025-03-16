FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:7b82b83612a1da268ffefae8714cc9e8d30d677076acc2d2b6f0dff584a0452d 

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