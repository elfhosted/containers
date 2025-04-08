FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/plexguide/Huntarr-Lidarr /source

FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY --from=cloner /source/main.py /source/config.py /source/api.py ./
COPY --from=cloner /source/missing/ ./missing/
COPY --from=cloner /source/upgrade/ ./upgrade/
COPY --from=cloner /source/utils/ ./utils/

# Default environment variables
ENV API_KEY="your-api-key" \
    API_URL="http://your-lidarr-address:8686" \
    HUNT_MISSING_ITEMS=1 \
    HUNT_UPGRADE_ALBUMS=0 \
    SLEEP_DURATION=900 \
    RANDOM_SELECTION="true" \
    MONITORED_ONLY="true" \
    HUNT_MISSING_MODE="artist" \
    DEBUG_MODE="false"

# Run the application
CMD ["python", "main.py"]