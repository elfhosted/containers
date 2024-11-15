# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/knightcrawler-stremio/knightcrawler.git /source

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ENV CLONE_PATH=/source/src/
ENV TARGETARCH=amd64

WORKDIR /src
COPY --from=cloner $CLONE_PATH/shared/ shared/
COPY --from=cloner $CLONE_PATH/producer/ producer/
WORKDIR /src/producer/src
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o /src/out -a $TARGETARCH

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.19

WORKDIR /app

ENV PYTHONUNBUFFERED=1

RUN apk add --update --no-cache python3 py3-pip && ln -sf python3 /usr/bin/python

COPY --from=build /src/out .

RUN rm -rf /app/python && mkdir -p /app/python

RUN pip3 install -r /app/requirements.txt -t /app/python

RUN addgroup -S producer && adduser -S -G producer producer

USER producer

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD pgrep -f dotnet || exit 1

ENV PYTHONNET_PYDLL=/usr/lib/libpython3.11.so.1.0

ENTRYPOINT ["dotnet", "Producer.dll"]