# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/xXCrash2BomberXx/YouTube-Stremio.git /source
# Use an official Node.js runtime as a parent image
# Using the Long-Term Support (LTS) version is a good practice
FROM node:18-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
# This leverages Docker's layer caching. These files don't change often,
# so this step will be cached, speeding up future builds.
COPY --from=cloner /source/package*.json ./

# Install app dependencies
RUN npm install

# Bundle app source
# Copy the rest of your app's source code from your host to your image filesystem.
COPY --from=cloner /source/. .

# Your app binds to port 7000, so you need to expose it
# The README.md's app_port should match this.
EXPOSE 7000

# Define the command to run your app
# This uses the "start" script from your package.json
CMD [ "npm", "start" ]