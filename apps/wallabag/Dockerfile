ARG VERSION
FROM wallabag/wallabag:${VERSION} as upstream

# No need to run as root, nor to listen on port 80
RUN sed -i 's/listen 80/listen 8000/' /etc/nginx/nginx.conf

# Add elfie
RUN \
    addgroup -S elfie --gid 568 \
        && adduser -S elfie -G elfie --uid 568 \

# We use "elfie" as our user, not "nobody"
RUN chown -R elfie:elfie /var/www/wallabag && \
    sed -i 's/nobody/elfie/' /entrypoint.sh && \
    sed -i 's/nobody/elfie/' /etc/php81/php-fpm.conf