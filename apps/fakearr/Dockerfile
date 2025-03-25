# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/elfhosted/fakearr.git /source

# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY --from=cloner /source/. /app

# Install any dependencies the app needs (e.g., Flask, xml, etc.)
RUN pip install --no-cache-dir -r requirements.txt

# Define environment variable (optional)
ENV FLASK_APP=app.py

# Run the application
CMD ["python", "fakearr.py"]
