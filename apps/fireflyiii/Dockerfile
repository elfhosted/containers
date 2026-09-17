FROM alpine:latest AS fetcher
ARG VERSION

RUN apk add --no-cache curl

# Upstream's release tarball ships composer vendor/ and the built frontend
# (public/build) already, so no composer or node build step is needed.
RUN curl -fsSL -o /firefly.tar.gz "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz" && \
    curl -fsSL -o /firefly.tar.gz.sha256 "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz.sha256" && \
    echo "$(cut -d' ' -f1 /firefly.tar.gz.sha256)  /firefly.tar.gz" | sha256sum -c - && \
    mkdir /source && \
    tar xzf /firefly.tar.gz -C /source && \
    rm -rf /source/storage/logs/* /source/tests /source/.env.testing

FROM php:8.5-fpm-alpine

RUN apk upgrade --no-cache && \
    apk add --no-cache \
        curl \
        dumb-init \
        icu-libs \
        icu-data-full \
        nginx \
        tzdata && \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev && \
    docker-php-ext-install -j$(nproc) bcmath intl && \
    apk del .build-deps && \
    rm -rf /tmp/* /usr/src/php.tar.xz

# Force our preferred user (remap www-data to 568 so php-fpm's default pool user matches)
RUN apk add --no-cache shadow && \
    groupmod -o -g 568 www-data && \
    usermod -o -u 568 -g 568 www-data && \
    apk del shadow

WORKDIR /app
COPY --from=fetcher /source/. /app/

COPY apps/fireflyiii/nginx.conf /etc/nginx/nginx.conf
COPY apps/fireflyiii/php-fpm.conf /usr/local/etc/php-fpm.d/zz-elfhosted.conf
COPY apps/fireflyiii/php.ini /usr/local/etc/php/conf.d/zz-elfhosted.ini
COPY apps/fireflyiii/entrypoint.sh /entrypoint.sh

# Laravel storage (SQLite DB, uploads, OAuth keys, sessions, cache) lives in /config.
# Laravel's runtime caches (config/events/routes) go to /tmp; the package and
# service manifests shipped in bootstrap/cache are static and stay read-only.
RUN chmod +x /entrypoint.sh && \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf && \
    mkdir -p /config && \
    chown 568:568 /config

ENV LARAVEL_STORAGE_PATH=/config \
    APP_CONFIG_CACHE=/tmp/laravel/config.php \
    APP_EVENTS_CACHE=/tmp/laravel/events.php \
    APP_ROUTES_CACHE=/tmp/laravel/routes.php \
    APP_ENV=production \
    APP_DEBUG=false \
    DB_CONNECTION=sqlite \
    LOG_CHANNEL=stdout \
    APP_LOG_LEVEL=notice \
    AUDIT_LOG_CHANNEL=audit_stdout \
    AUDIT_LOG_LEVEL=emergency \
    IS_DOCKER=true \
    TZ=UTC

USER 568

EXPOSE 8080

VOLUME /config

ENTRYPOINT ["dumb-init", "--single-child", "--"]
CMD ["/entrypoint.sh"]
