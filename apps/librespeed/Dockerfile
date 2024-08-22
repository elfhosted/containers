# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/librespeed/speedtest.git /source

FROM php:8-alpine

# Install extensions
RUN apk add --quiet --no-cache \
    bash \
    apache2 \
    apache2-ssl \
    php83-apache2 \
    php83-ctype \
    php83-openssl \
    php83-pdo_odbc \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libpq-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql pgsql \
    && rm -f /usr/src/php.tar.xz /usr/src/php.tar.xz.asc \
    && apk del --quiet --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libpq-dev

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# Prepare files and folders
RUN mkdir -p /speedtest/

# Copy sources
COPY --from=cloner /source/backend/ /speedtest/backend

COPY --from=cloner /source/results/*.php /speedtest/results/
COPY --from=cloner /source/results/*.ttf /speedtest/results/

COPY --from=cloner /source/*.js /speedtest/
COPY --from=cloner /source/favicon.ico /speedtest/

COPY --from=cloner /source/docker/servers.json /servers.json

COPY --from=cloner /source/docker/*.php /speedtest/
COPY --from=cloner /source/docker/entrypoint.sh /

# Prepare default environment variables
ENV TITLE=LibreSpeed
ENV MODE=standalone
ENV PASSWORD=password
ENV TELEMETRY=false
ENV ENABLE_ID_OBFUSCATION=false
ENV REDACT_IP_ADDRESSES=false
ENV WEBPORT=8000

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

# Final touches
EXPOSE 8000
CMD ["bash", "/entrypoint.sh"]