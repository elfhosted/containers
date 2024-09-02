# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/thomst08/requestrr.git /source

FROM node as node-build

COPY --from=cloner /source/ClientApp /app

WORKDIR /app

RUN npm install

RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:8.0 as dotnet-build

RUN apt-get update && \
  apt-get --no-install-recommends -y install nodejs npm

COPY --from=cloner /source/ /app
COPY --from=node-build /app /app/ClientApp

WORKDIR /app

RUN dotnet publish -c release -o publish Requestrr.WebApi.csproj
RUN rm -rf /app/publish/config
RUN rm -rf /app/publish/tmp
RUN mkdir /app/publish/config
RUN rm -f /app/publish/appsettings.Development.json

FROM mcr.microsoft.com/dotnet/aspnet:6.0

COPY --from=dotnet-build /app/publish/ /app/

# allow all users access to this so we can run container as non root.
RUN chmod -R 755 /app

WORKDIR /app/

ENV ASPNETCORE_URLS="http://*:4545"
EXPOSE 4545/tcp
ENTRYPOINT ["dotnet", "Requestrr.WebApi.dll"]