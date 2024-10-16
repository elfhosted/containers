ARG VERSION
FROM cloudb0x/autoscan:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:2fae8fc2d24a94a4762e061b2f72e0ef3d33cc2525d7ad479d25cc76de67b32b 

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
