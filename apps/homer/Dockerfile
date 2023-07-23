
ARG VERSION

FROM b4bz/homer:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:86565e3194a5e20728057da77482b2388b9b088f1921ac1a4986038730a48f01 

ENV GID 568
ENV UID 568
ENV PORT 8080
ENV SUBFOLDER "/_"
ENV INIT_ASSETS 1

USER root 

RUN apk add -U --no-cache lighttpd

WORKDIR /www

COPY --from=upstream /lighttpd.conf /lighttpd.conf
COPY --from=upstream /entrypoint.sh /entrypoint.sh
COPY --from=upstream --chown=${UID}:${GID} /www/ /www/

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