FROM node:22-alpine AS builder


# Add necessities for ttyd
RUN apk add --no-cache \
    ttyd \
    tmux \
    fish \
    bash \
    openssl \
    curl \
    jq

RUN npm install -g @peertube/peertube-cli

COPY --chown=568:568 apps/peertube/cli/peertube-cli.sh /
COPY --chown=568:568 apps/peertube/cli/launch-tmux.sh /
COPY --chown=568:568 apps/peertube/cli/entrypoint.sh /
COPY --chown=568:568 apps/peertube/cli/restricted.tmux.conf /

RUN mkdir -p /home/elfie && chown -R elfie /home/elfie

# Run elfie in rbash
RUN usermod -s /bin/bash elfie

USER 568

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]