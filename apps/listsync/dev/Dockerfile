# Use specific Python version
ARG PYTHON_VERSION=3.9
ARG NODE_VERSION=18

FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone https://github.com/Woahai321/list-sync.git  /source


# Multi-stage Dockerfile for Complete ListSync Web Application
# Includes: ListSync Core Service + FastAPI Backend + Next.js Frontend 

# Stage 1: Python Builder (ListSync + API)
FROM python:${PYTHON_VERSION}-slim AS python-builder

WORKDIR /usr/src/app

# Install build dependencies for Python packages that need compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry==1.8.3

# Copy Poetry configuration
COPY --from=cloner /source/pyproject.toml /source/poetry.lock ./

# Poetry settings
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=true \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Build virtual environment with dependencies
RUN --mount=type=cache,target=/tmp/poetry_cache poetry install --only main --no-root

# Install additional API dependencies
COPY --from=cloner /source/api_requirements.txt ./
RUN .venv/bin/pip install -r api_requirements.txt

# Stage 2: Node.js Builder (Frontend)
FROM node:${NODE_VERSION}-slim AS node-builder

WORKDIR /app/frontend

# Accept API URL as build argument and set as environment variable
ARG NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:4222/api}
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:4222/api}

# Copy package files
COPY --from=cloner /source/listsync-web/package*.json ./

# Install all dependencies (including dev dependencies for build) - clean install for Linux
RUN npm ci

# Copy frontend source (excluding node_modules to avoid Windows-specific files)
COPY --from=cloner /source/listsync-web/src ./src
COPY --from=cloner /source/listsync-web/public ./public
COPY --from=cloner /source/listsync-web/next.config.ts ./
COPY --from=cloner /source/listsync-web/postcss.config.mjs ./
COPY --from=cloner /source/listsync-web/tsconfig.json ./
COPY --from=cloner /source/listsync-web/next-env.d.ts ./
COPY --from=cloner /source/listsync-web/eslint.config.mjs ./

# Ensure proper permissions for Node.js binaries
RUN chmod +x node_modules/.bin/*

# Build the Next.js application with the API URL baked in
RUN npm run build

# Stage 3: Final Runtime Image
FROM python:${PYTHON_VERSION}-slim AS runtime

# Install system dependencies for Chrome, Node.js, and process management
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Chrome dependencies
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
    xvfb \
    dbus-x11 \
    xauth \
    # Node.js
    curl \
    # Process management
    supervisor \
    # Log rotation
    logrotate \
    # Timezone support
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set timezone - use environment variable if provided, otherwise try to detect from host
ENV TZ=${TZ:-UTC}

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Download and install Chrome and ChromeDriver
RUN wget -O /tmp/chrome-linux64.zip https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.204/linux64/chrome-linux64.zip && \
    unzip /tmp/chrome-linux64.zip -d /opt/ && \
    mv /opt/chrome-linux64 /opt/chrome && \
    ln -sf /opt/chrome/chrome /usr/bin/google-chrome && \
    chmod +x /usr/bin/google-chrome && \
    rm /tmp/chrome-linux64.zip && \
    \
    wget -O /tmp/chromedriver-linux64.zip https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.204/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver-linux64.zip -d /opt/ && \
    mv /opt/chromedriver-linux64/chromedriver /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver-linux64.zip

# Set environment variables for the final image
ENV TZ=GMT \
    SELENIUM_HOST=localhost \
    SELENIUM_PORT=4444 \
    RUNNING_IN_DOCKER=true \
    DISPLAY=:99 \
    SELENIUM_DRIVER_PATH=/usr/local/bin/chromedriver \
    PYTHONPATH=/usr/src/app \
    NO_SANDBOX=1

# Set working directory
WORKDIR /usr/src/app

# Copy Python virtual environment from builder
COPY --from=python-builder /usr/src/app/.venv .venv

# Copy built Next.js application from builder
COPY --from=node-builder /app/frontend/.next ./frontend/.next
COPY --from=node-builder /app/frontend/public ./frontend/public
COPY --from=node-builder /app/frontend/package*.json ./frontend/
COPY --from=node-builder /app/frontend/node_modules ./frontend/node_modules

# Ensure proper permissions for Node.js binaries in the final image
RUN chmod +x ./frontend/node_modules/.bin/*

# Copy application source code
COPY --from=cloner /source/. .

# Copy frontend configuration files
COPY --from=cloner /source/listsync-web/next.config.ts ./frontend/
COPY --from=cloner /source/listsync-web/postcss.config.mjs ./frontend/

# "activate" Python venv
ENV PATH="/usr/src/app/.venv/bin:$PATH"

# Create necessary directories
RUN mkdir -p /usr/src/app/data /tmp/.X11-unix /var/log/supervisor && \
    chmod 1777 /tmp/.X11-unix

# Set a default command so that we can goss-test
CMD [ "/usr/src/app/.venv/bin/python start_api.py" ]

# core: /usr/src/app/.venv/bin/python -m list_sync
# api: /usr/src/app/.venv/bin/python start_api.py
# frontend: npm start
# xvfb: /usr/bin/Xvfb :99 -screen 0 1024x768x24



