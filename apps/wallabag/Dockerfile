ARG VERSION
FROM wallabag/wallabag:${VERSION} as upstream

# No need to run as root, nor to listen on port 80
RUN sed -i '/listen 80/listen 8000/' /etc/nginx/nginx.conf