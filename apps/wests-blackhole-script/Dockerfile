FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/westsurname/scripts.git  /source

# Patch for probe support (we can't do inotify)
COPY apps/wests-blackhole-script/polling-no-inotify.patch /source/
RUN cd /source && git apply polling-no-inotify.patch && rm polling-no-inotify.patch

FROM python:3.9-slim

ARG SERVICE_NAME=blackhole

# Set working directory
WORKDIR /app

# Copy only the files needed for pip install to maximize cache utilization
COPY --from=cloner /source/requirements.txt ./

# Install Python dependencies
RUN grep -E "#.*($SERVICE_NAME|all)" requirements.txt | awk '{print $0}' > service_requirements.txt && \
    pip install --no-cache-dir -r service_requirements.txt

# Copy the rest of the application
COPY --from=cloner /source/. .

CMD ["python", "blackhole_watcher.py"]

# Add tmux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tmux

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

COPY --chown=568:568 apps/wests-blackhole-script/blackhole.sh /
COPY --chown=568:568 apps/wests-blackhole-script/launch-tmux.sh /
COPY --chown=568:568 apps/wests-blackhole-script/entrypoint.sh /
COPY --chown=568:568 apps/wests-blackhole-script/restricted.tmux.conf /

ENTRYPOINT ["/entrypoint.sh"]