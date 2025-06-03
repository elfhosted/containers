# Get the elfhosted code
ARG VERSION
FROM chocobozzz/peertube:${VERSION}-bookworm

# per https://github.com/Chocobozzz/PeerTube/issues/4622

# install dependencies for vaapi
RUN 	   apt update \
	&& apt install -y --no-install-recommends wget apt-transport-https \
	&& echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian/ $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) non-free" | tee /etc/apt/sources.list.d/non-free.list \
	&& echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian/ $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) non-free-firmware" | tee /etc/apt/sources.list.d/non-free-firmware.list \
    && apt update \
	&& apt install -y --no-install-recommends intel-media-va-driver-non-free vainfo i965-va-driver-shaders \
	&& rm /var/lib/apt/lists/* -fR