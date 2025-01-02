FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/g0ldyy/comet.git /source

# Revert removal of ED (for now)
RUN cd /source && \
    git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name" && \
    git revert d6922010290ebe62b56bc782859e8ad07e14daeb

# Patch out requirement for warp
COPY apps/comet/no-warp-necessary.patch /source/
RUN cd /source && git apply no-warp-necessary.patch && rm no-warp-necessary.patch

# Patch in the stremthru PR
RUN cd /source && \
    wget https://patch-diff.githubusercontent.com/raw/g0ldyy/comet/pull/166.patch && \
    git apply 166.patch


FROM python:3.11-alpine
LABEL name="Comet" \
      description="Stremio's fastest torrent/debrid search add-on." \
      url="https://github.com/g0ldyy/comet"

ARG BUILD_VERSION=UNKNOWN
ENV BUILD_VERSION=${VERSION}

WORKDIR /app


ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_HOME="/usr/local" \
    FORCE_COLOR=1 \
    TERM=xterm-256color \
    INDEXER_MANAGER_INDEXERS='["DMM public hash shares only"]' \
    INDEXER_MANAGER_API_KEY='fakeapikey'

# Fix python-alpine gcc
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    make

RUN pip install poetry
COPY --from=cloner /source/. .

# Set environment variables for the virtual environment path
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Create the virtual environment in the specified directory
RUN python -m venv $VIRTUAL_ENV

RUN poetry install --no-cache --no-root --without dev

RUN \
    addgroup -S elfie --gid 568 \
    && adduser -S elfie -G elfie --uid 568 \
    && chown elfie -R /app


USER 568

ENTRYPOINT ["poetry", "run", "python", "-m", "comet.main"]