FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:224fbe07e825d0ee91b483bd8403be754971bd0d4813689dbeb28a2435ab46d6 

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
