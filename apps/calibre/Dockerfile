FROM ghcr.io/elfhosted/ubuntu:focal-20240427@sha256:1b84c219a764d8da5ba0f4b2b1f80e7c6396a8c9dfb499f945549396b53b0821 

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
    mkdir -p /storage/elfstorage/books && \
    touch /storage/elfstorage/books/metadata.db && \
    chown 568 /storage/elfstorage/books/metadata.db

COPY ./apps/calibre/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]

USER 568
VOLUME /media
EXPOSE 8080
