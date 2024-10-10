ARG VERSION
FROM cloudb0x/autoscan:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:6ab3d945f706242c59518d185e003203de2c59702c04eebfbde6a5119f8f114a 

ENV \
  PATH="/app/autoscan:${PATH}" \
  AUTOSCAN_CONFIG="/config/config.yml" \
  AUTOSCAN_DATABASE="/config/autoscan.db" \
  AUTOSCAN_LOG="/config/activity.log" \
  AUTOSCAN_VERBOSITY="0" \
  HOME="/config" \
  XDG_CONFIG_HOME="/config" \
  XDG_DATA_HOME="/config"

# Copy autoscan binary from upstream
RUN mkdir /app/autoscan
COPY --from=upstream /app/autoscan/autoscan /app/autoscan/autoscan

EXPOSE 3030

COPY ./apps/autoscan/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
