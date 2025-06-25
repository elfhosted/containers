FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/wger-project/wger.git  /source

#
# Docker image for wger
#
# Please consult the README for usage
#
# Note: you MUST build this image from the project's root!
# docker build -f extras/docker/production/Dockerfile --tag wger/server .
#
# To run the container consult https://github.com/wger-project/docker

##########
# Builder
##########
FROM ghcr.io/elfhosted/wger-base:rolling AS builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install --no-install-recommends -y \
      build-essential \
      python3-dev \
      python3-wheel \
      pkg-config \
      libcairo2-dev \
      libjpeg8-dev \
      libwebp-dev \
      libpq-dev \
      rustc \
      yarnpkg \
      sassc \
      cargo

# Build the necessary python wheels
#
# PS: the --mount tmpfs is a workaround for https://github.com/rust-lang/cargo/issues/8719
#
# PPS: actually only pyproject.toml is needed here, but it seems there is no way
# to tell pip to only build the dependencies and not the project itself as well,
# so we copy enough to make this is possible
COPY --from=cloner /source/pyproject.toml .
COPY --from=cloner /source/wger/version.py ./wger/version.py
COPY --from=cloner /source/wger/__init__.py ./wger/__init__.py
COPY --from=cloner /source/README.md ./README.md

RUN --mount=type=tmpfs,target=/root/.cargo \
    pip3 wheel \
      --no-cache-dir \
      --wheel-dir /wheels \
      --group docker . \
    && pip3 install \
      --break-system-packages \
      --no-warn-script-location \
      --root-user-action ignore \
      --user \
      --no-cache-dir /wheels/* \
    && ln -s /usr/bin/yarnpkg /usr/bin/yarn \
    && ln -s /usr/bin/sassc /usr/bin/sass


# Download and copy js and css files
COPY --from=cloner /source/. /home/wger/src
WORKDIR /home/wger/src
RUN yarn install \
    && yarn build:css:sass


########
# Final
########
FROM ghcr.io/elfhosted/wger-base:rolling AS final
LABEL maintainer="Roland Geider <roland@geider.net>"
ENV PATH="/home/wger/.local/bin:$PATH"

EXPOSE 8000


# Set up the application
COPY --from=builder --chown=wger:wger /root/.local /home/wger/.local

WORKDIR /home/wger/src
COPY --chown=wger:wger . /home/wger/src
COPY --from=builder --chown=wger:wger /home/wger/src/wger/core/static/yarn /home/wger/src/wger/core/static/yarn
COPY --from=cloner /source/extras/docker/production/settings.py /home/wger/src
COPY --from=cloner /source/extras/docker/production/settings.py /tmp/
COPY --from=cloner /source/extras/docker/production/entrypoint.sh /home/wger/entrypoint.sh
COPY --from=cloner /source/extras/docker/production/celery/start-beat /start-beat
COPY --from=cloner /source/extras/docker/production/celery/start-worker /start-worker
COPY --from=cloner /source/extras/docker/production/celery/start-flower /start-flower
RUN chmod +x /home/wger/entrypoint.sh \
    && chmod +x /start-beat \
    && chmod +x /start-worker \
    && chmod +x /start-flower \
    && chown wger:wger /home/wger/src

USER wger
RUN pip3 install --break-system-packages --user --editable . \
    && mkdir ~/media \
    && mkdir ~/static \
    && mkdir ~/beat \
    && mkdir ~/db

CMD ["/home/wger/entrypoint.sh"]