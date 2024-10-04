ARG VERSION
FROM filebrowser/filebrowser:v${VERSION} as upstream


# # Until the TFA bug is fixed
# FROM filebrowser/filebrowser:v2.23.0 as upstream



# FROM ghcr.io/elfhosted/alpine:rolling@sha256:6b59b2060ffbb6af76654aae9f5185fbfdfb08b2532d0186f3b14e8ad26b7598 
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:17771c7928dba04e467101955fc54ca7b4ea7d52c940669eb7437a023a5cde92 


LABEL org.opencontainers.image.source = "https://github.com/filebrowser/filebrowser"

COPY --from=upstream /filebrowser /filebrowser
COPY apps/filebrowser/scripts/* /usr/local/bin/
COPY apps/filebrowser/branding /branding/

# So that we can allow use of the cd command, which doesn't actually exist in /bin/
USER root

ENV S6_OVERLAY_VERSION=3.2.0.0

# Possibly useful binaries
# RUN apk add --no-cache mlocate ncdu tree curl bash
RUN apt-get -y update && apt-get -y install curl xz-utils git tmux tree fish pipx python3-venv nano && \
    pipx ensurepath

# Add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN chown -R elfie:elfie /run

# Add kubectl command (weird, I know, but we use it for some console actions)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
   	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
	rm kubectl

# Get recyclarr
RUN curl -LO https://github.com/recyclarr/recyclarr/releases/latest/download/recyclarr-linux-x64.tar.xz && \
	tar xf \
	recyclarr-linux-x64.tar.xz -C \
	/usr/local/bin/ && \
	rm recyclarr-linux-x64.tar.xz

# splash-cli unsplash client
RUN \
    SPLASH_CLI_VERSION=$(curl -sX GET "https://api.github.com/repos/rawnly/splash-cli/releases/latest" \
    | jq -r .tag_name); \
  curl -o \
    /tmp/splash-cli.tar.gz -L \
    "https://github.com/rawnly/splash-cli/releases/download/${SPLASH_CLI_VERSION}/splash_${SPLASH_CLI_VERSION}_linux_amd64.tar.gz" && \
  tar zxvpf /tmp/splash-cli.tar.gz && \
  mv splash /usr/local/bin && \
  rm README.md


# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
    
# This is our fake bash for command execution
RUN cp -p /bin/bash /bin/vstat

# Run elfie in rbash
RUN usermod -s /bin/rbash elfie && \
    mkdir -p /storage/config && \
    ln -sf /home/elfie/.config/ /storage/config/elfterm

COPY --chown=568:568 apps/filebrowser/root /

USER 568

# We need plextraktsync
RUN pipx install PlexTraktSync

EXPOSE 8080

# Because filebrowser wants paths relative to its executable

WORKDIR /
ENTRYPOINT [ "/init" ]