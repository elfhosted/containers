FROM openjdk:jre-alpine as builder

FROM builder

ARG VERSION="2.1.0"
ENV LD_LIBRARY_PATH=/lib;/lib32;/usr/lib
ENV XDG_DOWNLOAD_DIR=/opt/JDownloader/Downloads
ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="C"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV UMASK=''
COPY ./${ARCH}/*.jar /opt/JDownloader/libs/
# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
RUN mkdir -p /opt/JDownloader/app && \
    apk add --update libstdc++ ffmpeg wget && \
    wget -O /opt/JDownloader/app/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar" && \
    chmod 777 /opt/JDownloader/ -R && \
    apk del wget --purge

COPY apps/jdownloader/daemon.sh /opt/JDownloader/
COPY apps/jdownloader/*.jar /opt/JDownloader/app/libs/
COPY apps/jdownloader/default-config.json.dist /opt/JDownloader/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json.dist
COPY apps/jdownloader/configure.sh /usr/bin/configure

WORKDIR /opt/JDownloader

CMD ["/opt/JDownloader/daemon.sh"]