FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/f0e/letterboxd-trakt-sync.git /source


FROM python:3.12-alpine

WORKDIR /app

RUN apk update && \
    apk add git ttyd tmux bash

ENV IN_DOCKER=true
ENV SCHEDULED=true

COPY --from=cloner /source/. .

# install requirements
RUN pip install --no-cache-dir -r requirements.txt


# Add ttyd
# ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd
# add local files
COPY --chown=568:568 apps/cinesync/cinesync.sh /
COPY --chown=568:568 apps/cinesync/launch-tmux.sh /
COPY --chown=568:568 apps/cinesync/entrypoint.sh /
COPY --chown=568:568 apps/cinesync/restricted.tmux.conf /

# Force our preferred user
ARG user=elfie
RUN addgroup -S elfie --gid 568 && adduser -S elfie -G elfie --uid 568
USER 568

# Run the application
ENTRYPOINT ["/entrypoint.sh"]