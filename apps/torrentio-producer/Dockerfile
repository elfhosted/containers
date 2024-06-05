FROM alpine:latest as cloner

ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  -b $CHANNEL https://github.com/elfhosted/torrentio.elfhosted.com.git /tmp/source

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /App

WORKDIR /App
COPY --from=cloner /tmp/source/src/producer /App


ENV PORT 7001

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "Producer.dll"]