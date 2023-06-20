ARG VERSION
FROM shokoanime/server:${VERSION} as upstream

RUN apt-get update && apt-get install -y mono-runtime libmono-system-xml-linq4.0-cil && \
    addgroup shokogroup --gid 568 && \
    adduser shoko \
        --uid 568 \
        --ingroup shokogroup \
        --system \
        --disabled-password \
        --home /home/shoko && \
    mkdir -p /home/shoko/.shoko && \
    chown shoko /home/shoko/.shoko
        
USER 568

# bypass the upstream dockerentrypoint which changes permissions and does stuff we don't need
ENTRYPOINT /usr/src/app/build/Shoko.CLI
