FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/g0ldyy/comet.git /source

FROM ghcr.io/astral-sh/uv:python3.11-alpine
LABEL name="Comet" \
      description="Stremio's fastest torrent/debrid search add-on." \
      url="https://github.com/g0ldyy/comet"

WORKDIR /app

ARG DATABASE_PATH

COPY --from=cloner /source/pyproject.toml .

RUN uv sync

COPY --from=cloner /source/. .

ENTRYPOINT ["uv", "run", "python", "-m", "comet.main"]