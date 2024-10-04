FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:17771c7928dba04e467101955fc54ca7b4ea7d52c940669eb7437a023a5cde92 

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KEPUBIFY_RELEASE=v4.0.4 # until we can work out how to do github auth on this query

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    ghostscript \
    libldap-2.5-0 \
    libmagic1 \
    libsasl2-2 \
    libxi6 \
    libxslt1.1 \
    python3-venv && \
    echo "**** install calibre-web ****" && \
    curl -o \
      /tmp/calibre-web.tar.gz -L \
      https://github.com/janeczku/calibre-web/archive/${VERSION}.tar.gz && \
    mkdir -p \
      /app/calibre-web && \
    tar xf \
      /tmp/calibre-web.tar.gz -C \
      /app/calibre-web --strip-components=1 && \
    cd /app/calibre-web && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r \
    requirements.txt -r \
    optional-requirements.txt && \
  echo "***install kepubify" && \
  if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
    KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /usr/bin/kepubify -L \
    https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit && \
  echo "**** cleanup ****" && \
  apt-get -y purge \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  apt-get -y autoremove && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /root/.cache

RUN echo "**** Fetch calibre bin ****" && \
 CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's/^v//g' ) && \ 
 mkdir -p \
    /app/calibre && \
 curl -o \
	/tmp/calibre.txz -L \
	"https://github.com/kovidgoyal/calibre/releases/download/v${CALIBRE_RELEASE}/calibre-${CALIBRE_RELEASE}-x86_64.txz" && \
 tar xf \
	/tmp/calibre.txz \
	-C /app/calibre && \
  mv /app/calibre/* /usr/bin/ && \
  rm -rf /app/calibre

USER 568
COPY ./apps/calibre-web/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

EXPOSE 8083

LABEL org.opencontainers.image.source="https://github.com/janeczku/calibre-web"

VOLUME /config