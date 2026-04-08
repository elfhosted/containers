# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG CACHE_BUST=1

RUN apk update && apk upgrade && \
    apk add --no-cache git && \
    echo "cache bust: ${CACHE_BUST}"

RUN git clone -b $VERSION https://github.com/TimilsinaBimal/Watchly.git /source

FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc curl ca-certificates\
    && rm -rf /var/lib/apt/lists/*

COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=cloner /source/app/ ./app/
COPY --from=cloner /source/main.py .

ENTRYPOINT ["python", "main.py"]