FROM cloudb0x/autoscan:latest as upstream

FROM ghcr.io/geek-cookbook/alpine-s6-overlay:3.1.6.2

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV \
  PATH="/app/autoscan:${PATH}" \
  AUTOSCAN_CONFIG="/config/config.yml" \
  AUTOSCAN_DATABASE="/config/autoscan.db" \
  AUTOSCAN_LOG="/config/activity.log" \
  AUTOSCAN_VERBOSITY="0"

# Copy autoscan binary from upstream
RUN mkdir /app/autoscan
COPY --from=upstream /app/autoscan/autoscan /app/autoscan/autoscan
COPY --from=upstream /etc/services.d/autoscan/run /etc/services.d/autoscan/run

# Volume
VOLUME ["/config"]

# Port
EXPOSE 3030