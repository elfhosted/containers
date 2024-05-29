ARG VERSION

FROM louislam/uptime-kuma:${VERSION}-alpine as upstream

FROM ghcr.io/geek-cookbook/alpine:3.19.1@sha256:9c7e1a891b92b261c034a8d9b77b19dd007cc5398ab958282fd9a152fc4c9b46

# for initial install
USER root

ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install apprise, iputils for non-root ping, setpriv
RUN apk add --no-cache iputils setpriv dumb-init python3 py3-cryptography py3-pip py3-six py3-yaml py3-click py3-markdown py3-requests py3-requests-oauthlib nodejs npm && \
    pip3 --no-cache-dir install apprise==1.0.0 && \
    rm -rf /root/.cache

WORKDIR /app

# Copy app files from upstream
COPY --from=upstream /app /app

VOLUME /app/data

EXPOSE 3001

ENTRYPOINT ["/usr/bin/dumb-init", "--", "extra/entrypoint.sh"]
CMD ["node", "server/server.js"]
