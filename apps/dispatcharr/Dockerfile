# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Dispatcharr/Dispatcharr.git /source

# Define base image build arguments (must be before any FROM)
ARG REPO_OWNER=dispatcharr
ARG REPO_NAME=dispatcharr
ARG BASE_TAG=base

# --- Build frontend ---
FROM node:20 AS frontend-builder
WORKDIR /app/frontend
COPY --from=cloner /source/frontend /app/frontend
RUN corepack enable && corepack prepare yarn@stable --activate && \
    yarn install && yarn build && \
    rm -rf node_modules .cache

# --- Redeclare build arguments for the next stage ---
ARG REPO_OWNER
ARG REPO_NAME
ARG BASE_TAG

# --- Final image based on the dynamic base ---
FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}:${VERSION} AS final
ENV VIRTUAL_ENV=/dispatcharrpy
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
WORKDIR /app

# Copy application code
COPY --from=cloner /source/. /app
# Copy nginx configuration
COPY --from=cloner /source/docker/nginx.conf /etc/nginx/sites-enabled/default
# Clean out existing frontend folder
RUN rm -rf /app/frontend
# Copy built frontend assets
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# Run Django collectstatic
RUN python manage.py collectstatic --noinput

# Add timestamp argument
ARG TIMESTAMP

# Update version.py with build timestamp if provided
RUN if [ -n "$TIMESTAMP" ]; then \
    echo "Updating timestamp to ${TIMESTAMP} in version.py" && \
    sed -i "s|__timestamp__ = None.*|__timestamp__ = '${TIMESTAMP}'    # Set during CI/CD build process|" /app/version.py && \
    cat /app/version.py; \
    fi

ENTRYPOINT ["/app/docker/entrypoint.sh"]