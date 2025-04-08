FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/plexguide/Huntarr-Radarr /source

FROM python:3.9-slim
WORKDIR /app
# Install dependencies
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy application files
COPY --from=cloner /source/main.py /source/config.py /source/api.py /source/state.py ./
COPY --from=cloner /source/missing.py upgrade.py ./
COPY --from=cloner /source/utils/ ./utils/
# Create state directory
RUN mkdir -p /tmp/huntarr-state
# Default environment variables
ENV API_KEY="your-api-key" \
    API_URL="http://your-radarr-address:7878" \
    API_TIMEOUT="60" \
    HUNT_MISSING_MOVIES=1 \
    HUNT_UPGRADE_MOVIES=5 \
    SLEEP_DURATION=900 \
    STATE_RESET_INTERVAL_HOURS=168 \
    RANDOM_SELECTION="true" \
    MONITORED_ONLY="true" \
    DEBUG_MODE="false"
# Run the application
CMD ["python", "main.py"]