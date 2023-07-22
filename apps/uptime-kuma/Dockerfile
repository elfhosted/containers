ARG VERSION

FROM louislam/uptime-kuma:${VERSION}-alpine as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8b499524689e7006d18b0f564e4e5e8808dcc1d24a536dbc7c0c307301898683 

# for initial install
USER root

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
