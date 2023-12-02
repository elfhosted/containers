ARG VERSION
FROM crazymax/rtorrent-rutorrent:${VERSION} as upstream

RUN cd /var/www/rutorrent && \
    apk add --no-cache git openjdk17-jre-headless xz 7zip && \
    git clone https://github.com/xombiemp/rutorrentMobile.git mobile && \
    git clone https://github.com/nelu/rutorrent-filemanager.git plugins/filemanager && \
    cd /tmp && \
    git clone https://github.com/Novik/ruTorrent.git && \
    cp -rf /tmp/ruTorrent/plugins/httprpc /var/www/rutorrent/plugins/ && \
    rm -rf /tmp/ruTorrent && \
    apk del --force-broken-world git && \
    curl -o /tmp/filebot.xz -L "https://get.filebot.net/filebot/FileBot_5.0.1/FileBot_5.0.1-portable.tar.xz" && \
    mkdir -p /opt/filebot && \
    tar xvf /tmp/filebot.xz -C /opt/filebot && \
    rm -rf /tmp/filebot.xz && \
    ln -s /opt/filebot/filebot.sh /usr/local/bin/filebot

COPY apps/rutorrent/conf.php /var/www/rutorrent/plugins/filemanager/
