ARG VERSION
FROM wger/server:${VERSION}-dev
USER root

# Set default PUID and PGID
ENV PUID=568
ENV PGID=568

# Create default user and group
RUN groupadd -g ${PGID} elfie && \
    userdel wger && \
    useradd -u ${PUID} -g elfie -d /home/wger -s /bin/bash elfie && \
    chown elfie:elfie /home/wger -R

# Prepare for symlinks for static assets
RUN mkdir /config/static && \
    mkdir /config/media && \
    rm /home/wger/static && \
    rm /home/wger/media && \
    ln -s /config/static /home/wger/static && \
    ln -s /config/media /home/wger/media && \
    chown elfie:elfie /config -R

USER elfie
