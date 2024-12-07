FROM mikefarah/yq:4.44.6 as yq

FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:224fbe07e825d0ee91b483bd8403be754971bd0d4813689dbeb28a2435ab46d6

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG CHANNEL

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add GitHub repo so we can get the gh cli
# Per https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN type -p curl >/dev/null || (apt update && apt install curl -y) && \
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update \
	&& apt install gh -y

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
	tmux \
	ncdu \
	curl \
	tree \
	time \
	rsync \
	wget \
	sqlite3 \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* && \
	cd /tmp && \
	wget https://github.com/peak/s5cmd/releases/download/v2.2.2/s5cmd_2.2.2_Linux-64bit.tar.gz && \
	tar zxfvp s5cmd_2.2.2_Linux-64bit.tar.gz && \
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
    /tmp/splash-cli.tar.gz -L \
    "https://github.com/rawnly/splash-cli/releases/download/${SPLASH_CLI_VERSION}/splash_${SPLASH_CLI_VERSION}_linux_amd64.tar.gz" && \
  tar zxvpf /tmp/splash-cli.tar.gz && \
  mv splash /usr/local/bin && \
  rm README.md


# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

# cloudflare cli
RUN apt -y install nodejs npm && npm install -g cloudflare-cli

RUN curl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql.gpg > /dev/null && \
	echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main | tee -a /etc/apt/sources.list.d/postgresql.list && \
	apt-get update && \
	apt -y install postgresql-client-15	

# get wgcf (for generating WARP wireguard configs)
ADD --chmod=755  https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64 /usr/local/bin/wgcf

# Setup s3cmd config
# hadolint ignore=SC2016
RUN { \
		echo '[default]'; \
		echo 'access_key=$AWS_ACCESS_KEY'; \
		echo 'secret_key=$AWS_SECRET_KEY'; \
	} > ~/.s3cfg

COPY ./apps/tooling/scripts /scripts
COPY --chown=568:568 --chmod=755 ./apps/tooling/.bash_profile /home/elfie/


# Run elfie in rbash
RUN usermod -s /bin/rbash elfie

COPY --chown=568:568 apps/tooling/launch-tmux.sh /
COPY --chown=568:568 apps/tooling/entrypoint.sh /
COPY --chown=568:568 apps/tooling/restricted.tmux.conf /

# We need yq to merge yamls
COPY --from=yq /usr/bin/yq /usr/bin/yq  

RUN	 mkdir /home/elfie/programs && \
	 ln -s /usr/local/bin/kubectl /home/elfie/programs/ && \
	 ln -s /usr/bin/tmux /home/elfie/programs/ && \
	 ln -s /usr/local/bin/ttyd /home/elfie/programs/ && \
	 ln -s /usr/bin/tree /home/elfie/programs/ && \
	 ln -s /usr/bin/ncdu /home/elfie/programs/

WORKDIR /home/elfie
USER 568

# ENTRYPOINT ["rbash","-l","/entrypoint.sh"]
ENTRYPOINT [ "/entrypoint.sh" ]