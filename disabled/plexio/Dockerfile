# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/vanchaxy/plexio.git /source


FROM node:18.2.0-alpine as build

WORKDIR /app

COPY --from=cloner /source/frontend/package.json .
COPY --from=cloner /source/frontend/package-lock.json .

RUN npm install

COPY --from=cloner /source/frontend .

RUN npm run build

FROM unit:1.32.1-python3.11

WORKDIR /app

COPY --from=cloner /source/pyproject.toml pyproject.toml
COPY --from=cloner /source/plexio plexio

RUN pip install -e . --no-cache-dir

COPY --from=build /app/dist frontend

COPY --from=cloner /source/unit-nginx-config.json /docker-entrypoint.d/config.json
