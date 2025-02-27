ARG VERSION
FROM ghcr.io/woahai321/list-sync:${VERSION} as upstream

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \    
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /app --create-home --uid 568 --gid 568 --shell /bin/bash $user
RUN chown elfie /app
USER 568

# add local files
COPY --chown=568:568 apps/listsync/listsync.sh /
COPY --chown=568:568 apps/listsync/launch-tmux.sh /
COPY --chown=568:568 apps/listsync/entrypoint.sh /
COPY --chown=568:568 apps/listsync/restricted.tmux.conf /

# Run the application
# ENTRYPOINT ["/entrypoint.sh"]

ENTRYPOINT ["xvfb-run", "--server-args='-screen 0 1920x1080x24 -ac'", "--auto-servernum", "python", "add.py"]