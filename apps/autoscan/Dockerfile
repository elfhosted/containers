ARG VERSION
FROM cloudb0x/autoscan:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:e12c70c7e860b2b7b86be80ea3f06b9d70cd6e82cb48d6d89b5cb5d62b1d2cec 

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
