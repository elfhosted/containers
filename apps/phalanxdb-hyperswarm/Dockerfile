# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/godver3/phalanx_db_hyperswarm.git /source

FROM node:22

WORKDIR /app

# Copy package files
COPY --from=cloner /source/package*.json ./

# Install dependencies
RUN npm install

# Copy source files
COPY --from=cloner /source/*.js ./

# Create storage directories
RUN mkdir -p /app/p2p-db-storage /app/db_data

# Expose the default port
EXPOSE 8888

# Set up volumes for persistent storage
VOLUME ["/app/p2p-db-storage", "/app/db_data"]

# Copy .env file if it exists
COPY .env* ./

# Start the server
CMD ["npm", "run", "start:v4"] 