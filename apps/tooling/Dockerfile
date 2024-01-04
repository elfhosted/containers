FROM mikefarah/yq:4.33.3 as yq

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
	mysql-client \
	dumb-init \
	net-tools \
	vnstat \
	gpg \
	git \
	iproute2 \
	curl \
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


# Setup psql 15 client, which is not in ubuntu:focal/jammy yet:
RUN curl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql.gpg > /dev/null && \
	echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main | tee -a /etc/apt/sources.list.d/postgresql.list && \
	apt-get update && \
	apt -y install postgresql-client-15

# splash-cli unsplash client
RUN \
    SPLASH_CLI_VERSION=$(curl -sX GET "https://api.github.com/repos/rawnly/splash-cli/releases/latest" \
    | jq -r .tag_name); \
  curl -o \
    /tmp/splash-cli.zip -L \
    "https://github.com/rawnly/splash-cli/releases/download/${SPLASH_CLI_VERSION}/splash_${SPLASH_CLI_VERSION}_linux_amd64.tar.gz" && \
  unzip /tmp/splash-cli.zip && \
  mv /tmp/splash /usr/local/bin

RUN curl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql.gpg > /dev/null && \
	echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main | tee -a /etc/apt/sources.list.d/postgresql.list && \
	apt-get update && \
	apt -y install postgresql-client-15	

# Setup s3cmd config
# hadolint ignore=SC2016
RUN { \
		echo '[default]'; \
		echo 'access_key=$AWS_ACCESS_KEY'; \
		echo 'secret_key=$AWS_SECRET_KEY'; \
	} > ~/.s3cfg

COPY ./apps/tooling/scripts /scripts

# We need yq to merge yamls
COPY --from=yq /usr/bin/yq /usr/bin/yq  

USER 568

ENTRYPOINT [ "s3cmd" ]