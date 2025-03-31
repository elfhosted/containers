# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/caronc/apprise.git /source


## Upstream Dockerfile
# -*- coding: utf-8 -*-
# BSD 2-Clause License
#
# Apprise - Push Notification Library.
# Copyright (c) 2025, Chris Caron <lead2gold@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Base
FROM python:3.12-bookworm
RUN apt-get update && \
    apt-get install -y --no-install-recommends libdbus-1-dev libgirepository1.0-dev build-essential musl-dev bash dbus && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir dbus-python "PyGObject==3.44.2"

# Apprise Setup
VOLUME ["/apprise"]
WORKDIR /apprise
COPY --from=cloner /source/requirements.txt /
COPY --from=cloner /source/dev-requirements.txt /
ENV PYTHONPATH /apprise
ENV PYTHONPYCACHEPREFIX /apprise/__pycache__/py312

RUN pip install --no-cache-dir -r /requirements.txt -r /dev-requirements.txt

RUN addgroup --gid ${USER_GID:-568} apprise
RUN adduser --system --uid ${USER_UID:-568} --ingroup apprise --home /apprise --no-create-home --disabled-password apprise

USER apprise