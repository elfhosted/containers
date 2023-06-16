FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:83295fc8e3abf3d61503b7b694a88f838ab14143e7fe173cde0496a5a3084bc5 

ARG VERSION

RUN apt-get update && apt-get install -y \
    libfontconfig \
    libegl1 \
    xz-utils \
    libx11-6 \
    libxkbcommon0 \
    libglx0 \
    libopengl0 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxtst6 \
    libxkbfile1 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/calibre-tarball.txz -L "https://download.calibre-ebook.com/${VERSION}/calibre-${VERSION}-x86_64.txz" && \
    mkdir -p /opt/calibre && \
    tar xvf /tmp/calibre-tarball.txz -C /opt/calibre && \
    rm -rf /tmp/*

RUN /opt/calibre/calibre_postinstall && \
    mkdir -p /media/books && \
    touch /media/books/metadata.db && \
    chown 568 /media/books/metadata.db

COPY ./apps/calibre/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

USER 568
VOLUME /media
EXPOSE 8080
