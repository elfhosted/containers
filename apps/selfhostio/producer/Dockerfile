FROM alpine:latest as cloner
ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/geek-cookbook/torrentio.elfhosted.com.git /source

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
ENV CLONE_PATH=/source/src/producer
WORKDIR /App
COPY --from=cloner $CLONE_PATH/. .
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "Producer.dll"]