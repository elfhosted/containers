ARG VERSION
FROM filebrowser/filebrowser:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:de8a5005bc5d3ae169d3f54a190df394dee4d9ecbcab1f7be1f055905d4137c2 

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