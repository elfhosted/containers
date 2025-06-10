FROM node:22-alpine AS builder


# Add necessities for ttyd
RUN apk add --no-cache \
    ttyd \
    tmux \
    fish \
    bash \
    openssl \
    curl \
    jq \
    git

# Create user and group
RUN addgroup -g 568 elfie && \
    adduser -u 568 -G elfie -h /home/elfie -D elfie

RUN git clone https://github.com/Reseau-Canope/peertube-mass-uploader.git /opt/peertube-mass-uploader && \
    npm install -g @peertube/peertube-cli

COPY --chown=568:568 apps/peertube/cli/launch-tmux.sh /
COPY --chown=568:568 apps/peertube/cli/entrypoint.sh /

RUN mkdir -p /home/elfie && chown -R elfie /home/elfie

# Run elfie in rbash
RUN usermod -s /bin/bash elfie

USER 568

WORKDIR /config
ENTRYPOINT ["/entrypoint.sh"]