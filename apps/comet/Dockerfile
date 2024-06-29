# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/g0ldyy/comet.git /source



FROM python:3.11-alpine
LABEL name="Comet" \
      description="Stremio's fastest torrent/debrid search add-on." \
      url="https://github.com/g0ldyy/comet"

WORKDIR /app

ARG DATABASE_PATH

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_HOME="/usr/local" \
    FORCE_COLOR=1 \
    TERM=xterm-256color \
    INDEXER_MANAGER_INDEXERS='["FAKE_TO_PASS_TESTING"]'

# Fix python-alpine gcc
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    make

RUN pip install poetry
COPY --from=cloner /source/. .
RUN poetry install --no-cache --no-root --without dev

ENTRYPOINT ["poetry", "run", "python", "-m", "comet.main"]