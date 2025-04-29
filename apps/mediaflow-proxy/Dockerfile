# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/mhdzumair/mediaflow-proxy.git /source

# Now based on the upstream Dockerfile
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE="1"
ENV PYTHONUNBUFFERED="1"
ENV PORT="8888"

# Set work directory
WORKDIR /mediaflow_proxy

# Create a non-root user
RUN useradd -m mediaflow_proxy
RUN chown -R mediaflow_proxy:mediaflow_proxy /mediaflow_proxy

# Set up the PATH to include the user's local bin
ENV PATH="/home/mediaflow_proxy/.local/bin:$PATH"

# Switch to non-root user
USER mediaflow_proxy

# Install Poetry
RUN pip install --user --no-cache-dir poetry

# Copy only requirements to cache them in docker layer
COPY --from=cloner --chown=mediaflow_proxy:mediaflow_proxy /source/pyproject.toml /source/poetry.lock* /mediaflow_proxy/

# Project initialization:
RUN poetry config virtualenvs.in-project true \
    && poetry install --no-interaction --no-ansi --no-root --only main

# Temporary fix
RUN poetry add requests

# Copy project files
COPY --from=cloner --chown=mediaflow_proxy:mediaflow_proxy /source/. /mediaflow_proxy

# Expose the port the app runs on
EXPOSE 8888

# Activate virtual environment and run the application with Gunicorn
CMD ["poetry", "run", "gunicorn", "mediaflow_proxy.main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8888", "--timeout", "120", "--max-requests", "500", "--max-requests-jitter", "200", "--access-logfile", "-", "--error-logfile", "-", "--log-level", "info"]