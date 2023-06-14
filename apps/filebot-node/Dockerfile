ARG VERSION
FROM rednoah/filebot:node as upstream

RUN \
    adduser elfie \
        --uid 568 \
        --group \
        --system \
        --disabled-password \
        --home /data/node

ENTRYPOINT ["/opt/filebot-node/start"]
USER 568
