# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://gitlab.com/stremio-add-ons/annatar.git /source


# --- Build Stage ---
# Use the official Python 3.11 image as a base
FROM python:3.11-slim as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV POETRY_VERSION 1.7.1
ENV NUM_WORKERS 1

# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Set the working directory in the builder stage
WORKDIR /app

# Copy the pyproject.toml and poetry.lock files
COPY --from=cloner /source/pyproject.toml poetry.lock* /app/

# Install runtime dependencies using Poetry
# --no-dev: Skip installing development dependencies
# --no-root: Skip installing the root package (your package) at this stage
# --no-interaction: Do not prompt for input
# --no-ansi: Disable ANSI output
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-root --no-interaction --no-ansi

# Copy the rest of your application's code
COPY --from=cloner /source/annatar /app/annatar

# Build your application using Poetry
RUN poetry build

# --- Final Stage ---
FROM python:3.11-slim as final
ARG VERSION

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DB_PATH /app/data/annatar.db

ARG BUILD_VERSION=UNKNOWN
ENV BUILD_VERSION=${VERSION}

VOLUME /app/data
# Set the working directory in the container
WORKDIR /app

# Copy only the built wheel from the builder stage
COPY --from=builder /app/dist/*.whl /app/
# Install the application package
RUN pip install *.whl && rm *.whl

# Copy static website files
COPY --from=cloner /source/static /app/static
COPY --from=cloner /source/templates /app/templates
COPY --from=cloner /source/run.py /app/run.py

# ElfHosted branding
COPY apps/annatar/branding/configure.html.j2 /app/templates/

# Your application's default command, adjust as needed
CMD ["python", "run.py"]
