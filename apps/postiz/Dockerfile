# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# for now, just clone latest
RUN git clone -b $VERSION https://github.com/gitroomhq/postiz-app.git /source

FROM node:20-alpine3.19
RUN apk add --no-cache g++ make py3-pip supervisor bash caddy
RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

WORKDIR /app

COPY --from=cloner /source/. /app
COPY --from=cloner /source/var/docker/supervisord.conf /etc/supervisord.conf
COPY --from=cloner /source/var/docker/Caddyfile /app/Caddyfile
COPY --from=cloner /source/var/docker/entrypoint.sh /app/entrypoint.sh
COPY --from=cloner /source/var/docker/supervisord/caddy.conf /etc/supervisor.d/caddy.conf
RUN chmod +x /app/entrypoint.sh

RUN pnpm install
RUN pnpm run build

EXPOSE 4200

CMD ["pnpm", "run", "pm2"]