FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/westsurname/scripts.git  /source

FROM python:3.9-slim

ARG SERVICE_NAME=blackhole

# Set working directory
WORKDIR /app

# Copy only the files needed for pip install to maximize cache utilization
COPY --from=cloner /source/requirements.txt ./

# Install ALL Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY --from=cloner /source/. .

# Add tmux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tmux

# tokens.json needs to exist at /config
RUN sed -i "s|os.path.join(pathToScript, 'tokens.json')|'/config/tokens.json'|"

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

COPY --chown=568:568 apps/wests-blackhole-script/blackhole.sh /
COPY --chown=568:568 apps/wests-blackhole-script/launch-tmux.sh /
COPY --chown=568:568 apps/wests-blackhole-script/entrypoint.sh /
COPY --chown=568:568 apps/wests-blackhole-script/restricted.tmux.conf /

COPY --chown=568:568 --chmod=755 apps/wests-blackhole-script/request.sh /
COPY --chown=568:568 --chmod=755 apps/wests-blackhole-script/auth.sh /
COPY --chown=568:568 --chmod=755 apps/wests-blackhole-script/watchlist.sh /

ENTRYPOINT ["/entrypoint.sh"]