# Use official OpenJDK 21 image as base
FROM openjdk:21-jdk-slim

# Set working directory in the container
WORKDIR /app

# Install git and other necessary tools
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Clone the Debridav repository
RUN git clone https://github.com/skjaere/debridav.git .

# Build the project 
# Note: Adjust the build command based on the project's actual build process
# This example assumes Maven, but you might need to modify based on the project's build system
RUN ./gradlew bootJar

# Expose any necessary ports (adjust as needed)
EXPOSE 8080

# Command to run the application
# Replace with the actual command to start the application
CMD ["java", "-jar", "build/libs/debridav-*.jar"]
