
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

FROM ghcr.io/elfhosted/alpine:3.19.1@sha256:dfb0a18161228f317ed4c96630d70d7855d546a522c0017cbe76b907dabae8ec

ENV GID 568
ENV UID 568
ENV PORT 8080
ENV SUBFOLDER "/_"
ENV INIT_ASSETS 1
ENV IPV6_DISABLE 0

USER root 

RUN apk add -U --no-cache lighttpd git

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

EXPOSE ${PORT}

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]