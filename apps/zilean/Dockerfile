# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/iPromKnight/zilean.git /source

# Build Stage
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.19 AS base
ARG TARGETARCH
WORKDIR /build
COPY --from=cloner /source/. .
RUN dotnet restore -a $TARGETARCH
WORKDIR /build/src/Zilean.ApiService
RUN dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out
WORKDIR /build/src/Zilean.DmmScraper
RUN dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out

# Run Stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.19
RUN apk add --update --no-cache \
    python3  \
    py3-pip  \
    curl \
    && ln -sf python3 /usr/bin/python
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_gcServer=1
ENV DOTNET_GCDynamicAdaptationMode=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
ENV PYTHONUNBUFFERED=1
ENV ZILEAN_PYTHON_PYLIB=/usr/lib/libpython3.11.so.1.0
ENV ASPNETCORE_URLS=http://+:8181

WORKDIR /app
VOLUME /app/data
COPY --from=base /app/out .
COPY --from=base /build/requirements.txt .
RUN rm -rf /app/python || true && \
    mkdir -p /app/python || true
RUN pip3 install -r /app/requirements.txt -t /app/python

ENTRYPOINT ["./zilean-api"]