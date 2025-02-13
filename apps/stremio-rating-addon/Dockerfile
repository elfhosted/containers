# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  -b $CHANNEL https://github.com/hexdecimal16/stremio-rating-addon.git /source

# Use the official Node.js image as the base image
FROM node:22

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and yarn.lock to the working directory
COPY --from=cloner /source/package.json /source/yarn.lock ./

# Install project dependencies using yarn
RUN yarn install

# Copy the rest of the application code to the working directory
COPY --from=cloner /source/. .

# Expose the port that the app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]