# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Dictionarry-Hub/profilarr.git /source

# Dockerfile
FROM python:3.9-slim
WORKDIR /app

# Install git (since we're still using slim)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy pre-built files from dist directory
COPY --from=cloner /source/dist/backend/app ./app
COPY --from=cloner /source/dist/static ./app/static
COPY --from=cloner /source/dist/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

LABEL org.opencontainers.image.authors="Dictionarry dictionarry@pm.me"
LABEL org.opencontainers.image.description="Profilarr - Profile manager for *arr apps"
LABEL org.opencontainers.image.source="https://github.com/Dictionarry-Hub/profilarr"
LABEL org.opencontainers.image.title="Profilarr"
LABEL org.opencontainers.image.version="beta"

EXPOSE 6868

CMD ["gunicorn", "--bind", "0.0.0.0:6868", "app.main:create_app()"]