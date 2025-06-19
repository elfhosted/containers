# Get upstream code - we use node in this case
# we need node in this case for the metadata script
FROM node:22-alpine as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/Viren070/AIOStreams.git /source

WORKDIR /source

# Update metadata
RUN mkdir /resources && \
    npm run metadata

FROM node:22-alpine AS builder

WORKDIR /build

# Copy LICENSE file.
COPY --from=cloner /source/LICENSE ./

# Copy the relevant package.json and package-lock.json files.
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/packages/server/package*.json ./packages/server/
COPY --from=cloner /source/packages/core/package*.json ./packages/core/
COPY --from=cloner /source/packages/frontend/package*.json ./packages/frontend/

# Copy source files.
COPY --from=cloner /source/tsconfig.*json ./
COPY --from=cloner /source/packages/server ./packages/server
COPY --from=cloner /source/packages/core ./packages/core
COPY --from=cloner /source/packages/frontend ./packages/frontend
COPY --from=cloner /source/scripts ./scripts
COPY --from=cloner /source/resources ./resources

# Install dependencies.
RUN npm install

# Build the project.
RUN npm run build

# Remove development dependencies.
RUN npm --workspaces prune --omit=dev

FROM node:22-alpine AS final

WORKDIR /app

# Copy the built files from the builder.
# The package.json files must be copied as well for NPM workspace symlinks between local packages to work.
COPY --from=builder /build/package*.json /build/LICENSE ./

COPY --from=builder /build/packages/core/package.*json ./packages/core/
COPY --from=builder /build/packages/frontend/package.*json ./packages/frontend/
COPY --from=builder /build/packages/server/package.*json ./packages/server/

COPY --from=builder /build/packages/core/dist ./packages/core/dist
COPY --from=builder /build/packages/frontend/out ./packages/frontend/out
COPY --from=builder /build/packages/server/dist ./packages/server/dist

COPY --from=builder /build/resources ./resources

COPY --from=builder /build/node_modules ./node_modules

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:$PORT/api/v1/status || exit 1

EXPOSE $PORT

# These are defaults required to goss-test, and are expected to be overridden by the user.
ENV SECRET_KEY=712376047f57a47969bd1992bcbda764db35bd2d0d9b3ddd6b291683e6755aea \
    BASE_URL=https://example.com

ENTRYPOINT ["npm", "run", "start"]