ARG VERSION
FROM filebrowser/filebrowser:v${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 

LABEL org.opencontainers.image.source = "https://github.com/filebrowser/filebrowser"

COPY --from=upstream /filebrowser /filebrowser
COPY apps/filebrowser/scripts/* /usr/local/bin/
COPY apps/filebrowser/branding /branding/

# So that we can allow use of the cd command, which doesn't actually exist in /bin/
USER root

# Possibly useful binaries
RUN apk add --no-cache mlocate ncdu tree curl

# Add kubectl command (weird, I know, but we use it for some console actions)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
   	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
	rm kubectl
    
# This is our fake bash for command execution
RUN cp -p /bin/bash /bin/vstat

USER 568

# Use this so that dgoss works
ENV FB_DATABASE=/tmp/filebrowser.db

EXPOSE 8080

# Because filebrowser wants paths relative to its executable
WORKDIR /
ENTRYPOINT [ "/filebrowser" ]