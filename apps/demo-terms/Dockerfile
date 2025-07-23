# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION
ARG ZURG_GH_CREDS

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://$ZURG_GH_CREDS@github.com/elfhosted/demo-terms.git /source

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy app code
COPY --from=cloner /source/. /app

# Install only required Python packages
RUN pip install --no-cache-dir flask markdown

# Default port
EXPOSE 8080

# Run the app
CMD ["python", "app.py"]
