# Frontend Builder
FROM ghcr.io/dreulavelle/iceberg:dev@sha256:a3b6feca5fb95c01b9ca041580b3141e8bbfcacaf05ebc3d7d73818b02e73cc6 as upstream
FROM ghcr.io/geek-cookbook/alpine-node:20@sha256:34e579ce8fd045ec28105d0ee720e6d4b8fd332ebeb8d4890784b8b991d51e29

LABEL name="Iceberg" \
      description="Iceberg Debrid Downloader" \
      url="https://github.com/dreulavelle/iceberg"

RUN apk --update add python3 py3-pip bash shadow vim nano rclone && \
    rm -rf /var/cache/apk/*

WORKDIR /iceberg
ENV ORIGIN http://localhost:3000
ARG ORIGIN=http://localhost:3000
EXPOSE 3000 8080

# Frontend
COPY --from=upstream --chown=node:node /iceberg/frontend/build /iceberg/frontend/build
COPY --from=upstream --chown=node:node /iceberg/frontend/node_modules /iceberg/frontend/node_modules
COPY --from=upstream --chown=node:node /iceberg/frontend/package.json /iceberg/frontend/package.json

# Backend
COPY  --from=upstream /iceberg/backend/ /iceberg/backend
RUN python3 -m venv /venv
COPY  --from=upstream /iceberg/requirements.txt /iceberg/requirements.txt
RUN source /venv/bin/activate && pip install -r /iceberg/requirements.txt

COPY apps/iceberg/entrypoint.sh ./entrypoint.sh
# COPY apps/iceberg/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["/iceberg/entrypoint.sh"]

