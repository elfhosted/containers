# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/Pukabyte/fake-torrent-server.git /source

# Use an official Python base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file first (to leverage Docker cache)
COPY --from=cloner /source/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY --from=cloner /source/. .

# Expose port 8000 for FastAPI
EXPOSE 8000

# Run the application
CMD ["python", "fakearr.py"]