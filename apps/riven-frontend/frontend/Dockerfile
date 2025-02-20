# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/rivenmedia/riven-frontend.git /source


# Frontend Builder
FROM node:22-alpine AS frontend
WORKDIR /app
COPY --from=cloner /source/. .
RUN npm install -g pnpm && pnpm install
RUN pnpm run build && pnpm prune --prod

# Final Image
FROM node:22-alpine
LABEL name="Riven" \
    description="Riven Media Server: Frontend" \
    url="https://github.com/rivenmedia/riven-frontend"

# Set working directory
WORKDIR /riven

# Copy frontend build from the previous stage
COPY --from=frontend  /app/build /riven/build
COPY --from=frontend  /app/node_modules /riven/node_modules
COPY --from=frontend  /app/package.json /riven/package.json

COPY version.txt /riven/

ENTRYPOINT ["ORIGIN=$ORIGIN", "BACKEND_URL=$BACKEND_URL", "node", "/riven/build"]