# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/ARandomAddonDev/Statusio.git /source

FROM node:24-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY --from=cloner /source/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY --from=cloner /source/. .

# Build the TypeScript files
RUN npm run build

# Expose the port the app runs on
EXPOSE 7042

# Command to run the application
CMD ["node", "dist/app.js"]