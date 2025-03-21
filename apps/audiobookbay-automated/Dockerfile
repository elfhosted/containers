# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/JamesRy96/audiobookbay-automated.git /source

# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the app directory contents into the container
COPY --from=cloner /source/app /app

# Install any necessary dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Expose the port the app runs on
EXPOSE 5078

# Define the command to run the application
CMD ["python", "app.py"]