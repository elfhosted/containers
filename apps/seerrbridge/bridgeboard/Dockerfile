# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/Woahai321/SeerrBridge.git /source

# Use an official Node.js runtime as the base image
FROM node:20

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY --from=cloner /source/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the Node.js application code
COPY --from=cloner /source/. .

# Build the Next.js app for production
RUN npm run build

# Expose the port the Node.js app will run on
EXPOSE 3777

# Command to run the Node.js app
CMD ["npm", "start"]
