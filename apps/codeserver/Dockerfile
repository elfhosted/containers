ARG VERSION
FROM ghcr.io/coder/code-server:${VERSION}

# Install python deps
USER 0

ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3-pip \
      python3-venv
      
# Back to default user
USER 1000
