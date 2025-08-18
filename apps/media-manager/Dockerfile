# Get upstream code - we use node in this case
# we need node in this case for the metadata script
FROM node:22-alpine as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/maxdorninger/MediaManager.git /source

WORKDIR /source

FROM node:24-alpine AS frontend-build
WORKDIR /frontend
ARG VERSION
ARG BASE_PATH=""

COPY --from=cloner /source/web/package*.json ./
RUN npm ci && npm cache clean --force

COPY web/ ./
RUN env PUBLIC_VERSION=${VERSION} PUBLIC_API_URL=${BASE_PATH}/api/v1 BASE_PATH=${BASE_PATH}/web npm run build

FROM ghcr.io/astral-sh/uv:debian-slim
ARG VERSION
ARG BASE_PATH=""
LABEL author="github.com/maxdorninger"
LABEL version=${VERSION}
LABEL description="Docker image for MediaManager"

ENV PUBLIC_VERSION=${VERSION} \
    CONFIG_DIR="/config"\
    BASE_PATH=${BASE_PATH}\
    FRONTEND_FILES_DIR="/app/web/build"


WORKDIR /app

RUN apt-get update && \
    apt-get install -y ca-certificates bash libtorrent21 gcc bc locales postgresql mime-support curl gzip unzip tar 7zip bzip2 unar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY --from=cloner /source/pyproject.toml /source/uv.lock ./
RUN uv sync --locked

COPY --chmod=755 --from=cloner /source/mediamanager-startup.sh .
COPY --from=cloner /source/config.example.toml .
COPY --from=cloner /source/media_manager ./media_manager
COPY --from=cloner /source/alembic ./alembic
COPY --from=cloner /source/alembic.ini .

COPY --from=frontend-build /frontend/build /app/web/build

# Create user and group
RUN addgroup -g 568 elfie && \
    adduser -u 568 -G elfie -h /config -D elfie && \
    chown elfie /app -R

HEALTHCHECK CMD curl -f http://localhost:8000${BASE_PATH}/api/v1/health || exit 1
EXPOSE 8000
CMD ["/app/mediamanager-startup.sh"]