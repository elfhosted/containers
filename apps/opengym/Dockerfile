# openGym (https://github.com/DuarteSantos8/openGym) built from the release tag
# with the patches in patches/, API and web front in one image.

FROM alpine:latest AS cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b "v${VERSION}" --depth 1 https://github.com/DuarteSantos8/openGym.git /source \
 && rm -rf /source/.git

COPY apps/opengym/patches/ /patches/
RUN set -e; \
    cd /source; \
    for p in /patches/*.patch; do \
      echo "Applying ${p}"; \
      git apply "${p}" || exit 1; \
    done

FROM --platform=$BUILDPLATFORM node:22-alpine AS web
WORKDIR /app/frontend
COPY --from=cloner /source/frontend/package.json /source/frontend/package-lock.json ./
RUN npm ci --ignore-scripts
COPY --from=cloner /source/api/coach/core/ /app/api/coach/core/
COPY --from=cloner /source/frontend/ ./
RUN npm run build

FROM node:22-alpine AS api
WORKDIR /app
COPY --from=cloner /source/api/package.json /source/api/package-lock.json ./
RUN npm ci --omit=dev --omit=optional && npm cache clean --force

FROM alpine:latest AS nginxconf
RUN apk add --no-cache gettext
COPY --from=cloner /source/web/nginx.conf.template /tmp/nginx.conf.template
ENV NGINX_PORT=8080 \
    BACKEND=127.0.0.1 \
    PORT=3000 \
    RESOLVER=127.0.0.1 \
    CF_CONNECTING_IP="" \
    BASE_PATH="" \
    MEDIA_UPLOAD_MAX=48m
RUN envsubst '${NGINX_PORT} ${BACKEND} ${PORT} ${RESOLVER} ${CF_CONNECTING_IP} ${BASE_PATH} ${MEDIA_UPLOAD_MAX}' \
      < /tmp/nginx.conf.template > /tmp/opengym.conf \
 && if grep -nE '\$\{[A-Z_]+\}' /tmp/opengym.conf; then echo "unrendered template variable" >&2; exit 1; fi \
 && test "$(grep -c 'set $api_upstream http://127.0.0.1:3000;' /tmp/opengym.conf)" = 2 \
 && sed -i 's#set $api_upstream http://127.0.0.1:3000;#set $api_upstream http://opengym_api;#' /tmp/opengym.conf \
 && test "$(grep -c 'set $api_upstream http://opengym_api;' /tmp/opengym.conf)" = 2

FROM node:22-alpine
ARG VERSION

RUN apk upgrade --no-cache \
 && apk add --no-cache nginx tini \
 && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx \
 && rm -f /etc/nginx/http.d/default.conf

RUN addgroup -S elfie --gid 568 && adduser -S elfie -G elfie --uid 568

WORKDIR /app
COPY --from=api /app/node_modules ./node_modules
COPY --from=cloner /source/api/ ./
COPY --from=web /app/frontend/dist /usr/share/nginx/html
COPY --from=nginxconf /tmp/opengym.conf /etc/nginx/http.d/opengym.conf
COPY apps/opengym/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=755 apps/opengym/entrypoint.sh /usr/local/bin/opengym-entrypoint
COPY apps/opengym/hold.js /usr/local/lib/opengym-hold.js
COPY --from=cloner /source/catalogue/media/ /usr/share/nginx/html/exercise-media/

RUN mkdir -p /config && chown 568:568 /config \
 && nginx -t -e /dev/stderr -c /etc/nginx/nginx.conf \
 && rm -rf /tmp/* /var/lib/nginx/logs/*

ENV NODE_ENV=production \
    PORT=3000 \
    DATA_DIR=/config

USER 568

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/usr/local/bin/opengym-entrypoint"]
