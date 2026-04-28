# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/0xConstant1/stremio-addon-manager.git /source

# Apply our patches
COPY apps/stremio-addon-manager/patches/ /patches/
RUN cd /source && for p in /patches/*.patch; do echo "Applying $p" && git apply "$p"; done

FROM node:lts-alpine as builder

WORKDIR /app

COPY --from=cloner /source/package*.json /app
RUN npm install

COPY --from=cloner /source/. .
RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine3.22-perl as production-stage

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080