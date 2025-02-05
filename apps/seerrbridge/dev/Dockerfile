# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b dev https://github.com/Woahai321/SeerrBridge.git /source

FROM python:3.10

WORKDIR /app

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    libnss3 \
    libxss1 \
    libasound2 \
    fonts-liberation \
    libappindicator3-1 \
    libgbm-dev \
    libgtk-3-0 \
    libx11-xcb1 \
    libxtst6 \
    xdg-utils \
    libglib2.0-0 \
    libdrm2 \
    libxrandr2 \
    ca-certificates \
    tmux \
    dialog

# Download and install Chrome (specific version)
RUN wget -O /tmp/chrome-linux64.zip https://storage.googleapis.com/chrome-for-testing-public/133.0.6943.53/linux64/chrome-linux64.zip && \
    unzip /tmp/chrome-linux64.zip -d /opt/ && \
    mv /opt/chrome-linux64 /opt/chrome && \
    ln -sf /opt/chrome/chrome /usr/bin/google-chrome && \
    chmod +x /usr/bin/google-chrome

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd


# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /app --create-home --uid 568 --gid 568 --shell /bin/bash $user
RUN chown elfie /app
USER 568

# add local files
COPY --chown=568:568 apps/seerrbridge/seerrbridge.sh /
COPY --chown=568:568 apps/seerrbridge/launch-tmux.sh /
COPY --chown=568:568 apps/seerrbridge/entrypoint.sh /
COPY --chown=568:568 apps/seerrbridge/restricted.tmux.conf /


# Set environment variables
ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROME_DRIVER_PATH=/usr/local/bin/chromedriver
ENV RUNNING_IN_DOCKER=true

# Copy requirements and install them
COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY --from=cloner /source/. .

# Expose the application port (if needed)
EXPOSE 8777


# Run the application
ENTRYPOINT ["/entrypoint.sh"]