# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b https://github.com/SebastianMorel/AIOLists.git /source

# Use an official Node.js runtime as a parent image
FROM node:18-alpine As builder

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (or npm-shrinkwrap.json)
COPY --from=cloner /source/package*.json ./

# Install app dependencies
# Use 'npm ci' for faster, more reliable installs in CI/CD environments
RUN npm ci --only=production

# Copy app source code
COPY --from=cloner /source/. .

# --- Release Stage ---
FROM node:18-alpine

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app ./

# Set environment variables
ENV NODE_ENV=production
ENV PORT=7000

# Expose port 7000
EXPOSE 7000

# Command to run the application
CMD [ "npm", "run", "prod" ]