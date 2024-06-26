ARG VERSION
FROM filebrowser/filebrowser:v${VERSION} as upstream

# # Until the TFA bug is fixed
# FROM filebrowser/filebrowser:v2.23.0 as upstream



# FROM ghcr.io/elfhosted/alpine:rolling@sha256:6b59b2060ffbb6af76654aae9f5185fbfdfb08b2532d0186f3b14e8ad26b7598 
FROM ghcr.io/elfhosted/ubuntu:focal-20240427@sha256:1b84c219a764d8da5ba0f4b2b1f80e7c6396a8c9dfb499f945549396b53b0821 


LABEL org.opencontainers.image.source = "https://github.com/filebrowser/filebrowser"

COPY --from=upstream /filebrowser /filebrowser
COPY apps/filebrowser/scripts/* /usr/local/bin/
COPY apps/filebrowser/branding /branding/

# So that we can allow use of the cd command, which doesn't actually exist in /bin/
USER root

# Possibly useful binaries
# RUN apk add --no-cache mlocate ncdu tree curl bash
RUN apt-get -y update && apt-get -y install curl xz-utils git tree

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
    
# This is our fake bash for command execution
RUN cp -p /bin/bash /bin/vstat

USER 568
# Use this so that dgoss works
ENV FB_DATABASE=/tmp/filebrowser.db

EXPOSE 8080

# Because filebrowser wants paths relative to its executable
WORKDIR /
ENTRYPOINT [ "/filebrowser" ]