# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG CACHE_BUST=1

RUN apk update && apk upgrade && \
    apk add --no-cache git && \
    echo "cache bust: ${CACHE_BUST}"

RUN git clone https://github.com/TimilsinaBimal/Watchly.git /source

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc curl ca-certificates\
    && rm -rf /var/lib/apt/lists/*

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

COPY --from=cloner /source/app/ ./app/
COPY --from=cloner /source/main.py .
COPY --from=cloner /source/pyproject.toml .
COPY --from=cloner /source/uv.lock .

RUN uv sync --locked

ENTRYPOINT ["uv", "run", "main.py"]