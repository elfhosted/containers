FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:dadd2618e807a478ba519b9ed48707955ea2f1dd7ed41dd236a73d3eb968a95e

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y \
	ca-certificates \
	s3cmd \
  	iptables \
	inotify-tools \
	tcpdump \
	dumb-init \
	net-tools \
	vnstat \
	git \
	iproute2 \
	tree \
	time \
	rsync \
	wget \
	sqlite3 \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* && \
	cd /tmp && \
	wget https://github.com/peak/s5cmd/releases/download/v2.1.0-beta.1/s5cmd_2.1.0-beta.1_Linux-64bit.tar.gz && \
	tar zxfvp s5cmd_2.1.0-beta.1_Linux-64bit.tar.gz && \
	mv s5cmd /usr/local/bin/ && \
	chmod 755 /usr/local/bin/s5cmd

# Setup s3cmd config
# hadolint ignore=SC2016
RUN { \
		echo '[default]'; \
		echo 'access_key=$AWS_ACCESS_KEY'; \
		echo 'secret_key=$AWS_SECRET_KEY'; \
	} > ~/.s3cfg

COPY ./apps/tooling/scripts /scripts

USER 568

ENTRYPOINT [ "s3cmd" ]