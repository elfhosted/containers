# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/librespeed/speedtest.git /source


FROM php:8-apache

# use docker-php-extension-installer for automatically get the right packages installed
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install extensions
RUN install-php-extensions iconv gd pdo pdo_mysql pdo_pgsql pgsql

RUN rm -f /usr/src/php.tar.xz /usr/src/php.tar.xz.asc \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

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
ENV WEBPORT=8080

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

# Final touches
CMD ["bash", "/entrypoint.sh"]