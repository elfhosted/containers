# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/g0ldyy/comet.git /source


## Upstream Dockerfile

# --- Build Stage ---
FROM python:3.11
LABEL name="Comet" \
        description="Comet Strmeio Addon" \
        url="https://github.com/g0ldyy/comet"

# This is to prevent Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Install Poetry
RUN pip install poetry==1.8.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Set working directory
WORKDIR /app

# Copy the application code
COPY --from=cloner source/. ./

RUN poetry install --no-root

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "run.py"]