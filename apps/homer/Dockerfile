
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/bastienwirtz/homer.git /source

# build stage
FROM node:22-alpine3.19 as build-stage

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN corepack use pnpm@8

WORKDIR /app

COPY --from=cloner /source/package.json /source/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY --from=cloner /source/. .
RUN pnpm build


# build stage
FROM --platform=$BUILDPLATFORM node:22-alpine3.21 AS build-stage

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack use pnpm@10

WORKDIR /app

COPY --from=cloner source/package.json source/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY --from=cloner source/. .
RUN pnpm build

# production stage
FROM alpine:3.21

LABEL \
    org.label-schema.schema-version="1.0" \
    org.label-schema.version="$VERSION_TAG" \
    org.opencontainers.image.title="Homer Image" \
    org.opencontainers.image.description="A dead simple static Home-Page for your server to keep your services on hand, from a simple yaml configuration file." \
    org.opencontainers.image.ref.name="b4bz/homer:${VERSION_TAG}" \
    org.opencontainers.image.version="$VERSION_TAG" \
    org.opencontainers.image.licenses="Apache-2.0 license" \
    org.opencontainers.image.source="https://github.com/bastienwirtz/homer" \
    org.opencontainers.image.url="https://hub.docker.com/r/b4bz/homer"

ENV GID=568 \
    UID=568 \
    PORT=8080 \
    SUBFOLDER="/_" \
    INIT_ASSETS=1 \
    IPV6_DISABLE=0

RUN addgroup -S lighttpd -g ${GID} && adduser -D -S -u ${UID} lighttpd lighttpd && \
    apk add -U --no-cache tzdata lighttpd

WORKDIR /www

COPY --from=cloner /source/lighttpd.conf /lighttpd.conf
COPY --from=cloner /source/lighttpd-ipv6.sh /etc/lighttpd/ipv6.sh
COPY --from=cloner /source/entrypoint.sh /entrypoint.sh

COPY --from=build-stage --chown=${UID}:${GID} /app/dist /www/
COPY --from=build-stage --chown=${UID}:${GID} /app/dist/assets /www/default-assets


# Copy extra theme icons
WORKDIR /www/assets
# hadolint ignore=DL3047
RUN rm -rf /www/assets/* && \
	wget https://github.com/walkxcode/homer-theme/archive/refs/heads/main.zip && \
	unzip main.zip && \
	mv homer-theme-main/assets/* ./ && \
	rm main.zip && \
	rm -rf home-theme-main && \

	wget https://github.com/walkxcode/dashboard-icons/archive/refs/heads/main.zip && \
	unzip main.zip && \
	mv dashboard-icons-main/png ./ && \
	rm main.zip && \
	rm -rf dashboard-icons-main && \
	mkdir -p backgrounds

COPY ./apps/homer/png/*.png png/
COPY ./apps/homer/backgrounds/* backgrounds/

COPY ./apps/homer/favicon/* /www/assets/icons/

USER ${UID}:${GID}

HEALTHCHECK --start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:${PORT}/ || exit 1

EXPOSE ${PORT}

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]