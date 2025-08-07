# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# for now, just clone latest
RUN git clone -b $VERSION https://github.com/gitroomhq/postiz-app.git /source

FROM node:20-alpine3.19
ARG NEXT_PUBLIC_VERSION
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION
RUN apk add --no-cache g++ make py3-pip bash nginx
RUN adduser -D -g 'www' www
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www

RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

WORKDIR /app

COPY --from=cloner /source/. /app
COPY --from=cloner /source/var/docker/nginx.conf /etc/nginx/nginx.conf

RUN pnpm install
RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm run build

EXPOSE 4200

CMD ["pnpm", "run", "pm2"]