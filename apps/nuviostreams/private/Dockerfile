# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b private https://github.com/tapframe/NuvioStreamsAddon.git /source

FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY --from=cloner /source/package*.json ./
RUN npm install --production

# Copy the rest of the app
COPY --from=cloner /source/. .

# Expose port (change if your server uses a different port)
EXPOSE 3000

# Set environment variables (optional, can also be set at runtime)
ENV VERCEL=true \
    DISABLE_CACHE=false \
    SHOWBOX_PROXY_URL_VALUE="https://starlit-valkyrie-39f5ab.netlify.app/?destination=" \
    SCRAPER_MODE=proxy \
    USE_SCRAPER_API=false

RUN addgroup -S elfie --gid 568 \
 && adduser -S elfie -G elfie --uid 568 \
 && chown elfie:elfie /app

USER elfie

# Start the server
CMD ["node", "server.js"]