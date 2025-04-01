FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

ARG VERSION

# Install Node.js for UI build
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# Set working directory
WORKDIR /app

# Clone Radarr source
RUN git clone -b v$VERSION https://github.com/Radarr/Radarr.git /app/Radarr

# Set working directory inside the cloned repository
WORKDIR /app/Radarr

# Restore dependencies
RUN dotnet restore src/Radarr.sln
RUN npm install

# Build Radarr
RUN dotnet publish src/Radarr.Console -c Release -o /out

# Final image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app
COPY --from=build /out .

# Expose Radarr default port
EXPOSE 7878

# # Run Radarr
# CMD ["./Radarr"]


USER 568

ENV COMPlus_EnableDiagnostics=0

COPY ./apps/radarr/config.xml.tmpl /app/config.xml.tmpl
COPY ./apps/radarr/entrypoint.sh /entrypoint.sh
COPY ./apps/radarr/elf-import.sh /elf-import.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Radarr/Radarr"