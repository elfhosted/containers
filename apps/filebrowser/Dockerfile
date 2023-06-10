ARG VERSION
FROM filebrowser/filebrowser:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:761ae0cc8203517a5ce76527eea053bcf12689f59c0a4cf334cb380f64c60c60

LABEL org.opencontainers.image.source = "https://github.com/filebrowser/filebrowser"

COPY --from=upstream /filebrowser /filebrowser
COPY apps/filebrowser/cd.sh /bin/cd

# So that we can allow use of the cd command, which doesn't actually exist in /bin/
USER root

# Possibly useful binaries
RUN apk add --no-cache mlocate ncdu tree

# This is our fake bash for command execution
RUN cp -p /bin/bash /bin/vstat

USER 568

# Use this so that dgoss works
ENV FB_DATABASE=/tmp/filebrowser.db

EXPOSE 8080

# Because filebrowser wants paths relative to its executable
WORKDIR /
ENTRYPOINT [ "/filebrowser" ]