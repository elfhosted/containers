# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/ThePhaseless/Byparr.git /source

FROM debian:bullseye-slim AS base

ARG GITHUB_BUILD=false \
    VERSION

# Create non-root user with UID 568 and set home to /home/appuser
RUN useradd -u 568 -m -d /home/appuser -s /bin/bash appuser

# Set HOME for the rest of the build
ENV HOME=/home/appuser \
    GITHUB_BUILD=${GITHUB_BUILD} \
    VERSION=${VERSION} \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DISPLAY=:0

ENV PATH="${HOME}/.local/bin:$PATH"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests xauth xvfb scrot curl chromium chromium-driver ca-certificates

# Make sure appuser owns home and cache dirs
RUN chown -R 568:568 /home/appuser /app

# Still as root at this point
ADD https://astral.sh/uv/install.sh install.sh
RUN chmod +x install.sh && chown 568:568 install.sh

# Still as root
RUN mkdir -p /home/appuser/.cache/uv && \
    chown -R 568:568 /home/appuser /app

# Switch to non-root user AFTER setting permissions
USER 568
RUN ./install.sh

COPY --from=cloner /source/pyproject.toml /source/uv.lock ./
RUN uv sync

# SeleniumBase does not come with an arm64 chromedriver binary
RUN cd .venv/lib/*/site-packages/seleniumbase/drivers && ln -s /usr/bin/chromedriver uc_driver

COPY --from=cloner /source/. .

FROM base AS test

RUN --mount=type=cache,target=${HOME}/.cache/uv uv sync --group test
RUN ./test.sh

FROM base

EXPOSE 8191
HEALTHCHECK --interval=15m --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "http://localhost:8191/health" ]
CMD ["./cmd.sh"]
