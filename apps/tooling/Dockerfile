FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:4de1d348d364db1fee3581591cea174c677f68852c7dfd1009583fa1317851dc

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
	chmod 755 /usr/local/bin/s5cmd && \
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
   	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
	rm kubectl && \
	curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
	unzip rclone-current-linux-amd64.zip && \
	mv rclone-*-linux-amd64/rclone /usr/local/bin && \
	rm -rf mv rclone-*-linux-amd64 && \
	chown root:root /usr/local/bin/rclone && \
	chmod 755 /usr/local/bin/rclone


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