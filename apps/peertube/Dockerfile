# Get the elfhosted code
ARG VERSION
FROM chocobozzz/peertube:${VERSION}

# per https://github.com/Chocobozzz/PeerTube/issues/4622

# install dependencies for vaapi
RUN 	   apt update \
	&& apt install -y --no-install-recommends wget apt-transport-https \
	&& echo "deb http://deb.debian.org/debian/ $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) non-free" | tee /etc/apt/sources.list.d/non-free.list \
	&& apt update \
	&& apt install -y --no-install-recommends vainfo i965-va-driver-shaders \
	&& apt install -y --no-install-recommends python3 \
	&& rm /var/lib/apt/lists/* -fR
