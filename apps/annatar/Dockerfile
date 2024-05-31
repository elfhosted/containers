# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://gitlab.com/stremio-add-ons/annatar.git /source


## Upstream Dockerfile

# --- Build Stage ---
FROM python:3.11 as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_VERSION=1.7.1

# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Set the working directory in the builder stage
WORKDIR /app

# Copy the pyproject.toml and poetry.lock files
COPY --from=cloner /source/pyproject.toml /source/poetry.lock* /app/

# Install runtime dependencies using Poetry and create wheels for them
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-root --no-interaction --no-ansi \
    && poetry export -f requirements.txt --output requirements.txt --without-hashes \
    && pip wheel --no-cache-dir --no-deps --wheel-dir /tmp/wheels -r requirements.txt

# Copy the rest of your application's code
COPY --from=cloner /source/annatar /app/annatar

# Build your application using Poetry
RUN poetry build

# --- Final Stage ---
FROM python:3.11-slim as final

# Need this to set the build version - ElfHosted
ARG VERSION

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DB_PATH=/app/data/annatar.db
ENV NUM_WORKERS 4
ENV CONFIG_FILE=/config/annatar.yaml

VOLUME /app/data
WORKDIR /app

# Copy wheels and built wheel from the builder stage
COPY --from=builder /app/dist/*.whl /tmp/wheels/
COPY --from=builder /tmp/wheels/*.whl /tmp/wheels/

# # Install the application package along with all dependencies
RUN pip install /tmp/wheels/*.whl && rm -rf /tmp/wheels

# # Copy static and template files
COPY --from=cloner source/static /app/static
COPY --from=cloner source/templates /app/templates

COPY --from=cloner source/run.py /app/run.py

ARG BUILD_VERSION=UNKNOWN
ENV BUILD_VERSION=${VERSION}

COPY --from=cloner source/entrypoint.sh /app/entrypoint.sh

# ElfHosted branding
COPY apps/annatar/branding/branding.html.j2 /app/templates/

CMD ["sh", "/app/entrypoint.sh"]
