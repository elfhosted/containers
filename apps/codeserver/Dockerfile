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
      python3-venv \
      fish
      

      RUN \
      adduser elfie \
          --uid 568 \
          --group \
          --system \
          --disabled-password \
          --home /config/codeserver \
          --shell /bin/fish

WORKDIR /config/codeserver
# Back to default user
USER 568
