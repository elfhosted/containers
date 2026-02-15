ARG VERSION
FROM ghcr.io/seerr-team/seerr:${VERSION} as upstream

USER root
RUN sed -i -e 's/^node:x:1000:1000:/node:x:568:568:/' /etc/passwd /etc/group && \
	chown -R 568:568 /app
USER 568:568

