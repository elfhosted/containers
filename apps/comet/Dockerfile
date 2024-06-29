# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/g0ldyy/comet.git /source


FROM python:3.11
LABEL name="Comet" \
      description="Stremio's fastest torrent/debrid search add-on." \
      url="https://github.com/g0ldyy/comet"

# This is to prevent Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Install Poetry
RUN pip install poetry

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    HOST=0.0.0.0 \
    FASTAPI_WORKERS=1 \
    INDEXER_MANAGER_INDEXERS='["FAKE_TO_PASS_TESTING"]' \
    DATABASE_PATH=/config

# Set working directory
WORKDIR /app

# Copy the application code
COPY --from=cloner /source/. ./

RUN poetry install --no-root

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Set environment variables for uvicorn
ENV FASTAPI_HOST=0.0.0.0
ENV FASTAPI_PORT=8000

# Use uvicorn to run the application
CMD ["uvicorn", "comet.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]