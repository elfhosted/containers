# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/sooti/stremio-addon-debrid-search.git /source

# Apply ElfHosted tweaks
COPY apps/sootio/elfhosted-branding.patch /source/elfhosted-branding.patch
RUN cd /source && \
    git apply elfhosted-branding.patch


# Use an official Node.js image
FROM node:20

# Set working directory inside container
WORKDIR /app

# Copy only package.json and package-lock.json first (better build caching)
COPY --from=cloner /source/package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the project files
COPY --from=cloner /source/. .

# Expose app port (optional, e.g. if your app runs on 3000)
EXPOSE 6907

# Start the dev server (using nodemon or your dev script)
CMD ["npm", "run", "start"]