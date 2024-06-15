ARG VERSION
FROM ghcr.io/coder/code-server:${VERSION}

# Install python deps
USER 0

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3-pip \
      python3-venv && \
      pip install poetry

# Back to default user
USER 1000
