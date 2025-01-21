# Use official OpenJDK 21 image as base
FROM openjdk:21-jdk-slim as base
ARG VERSION

# Set working directory in the container
WORKDIR /app

# Install git and other necessary tools
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Clone the Debridav repository
RUN git clone -b $VERSION https://github.com/skjaere/debridav.git .

# Build the project 
# Note: Adjust the build command based on the project's actual build process
# This example assumes Maven, but you might need to modify based on the project's build system
RUN ./gradlew bootJar

FROM openjdk:21-jdk-slim
WORKDIR /app

COPY --from=base /app/build/libs/debridav*.jar /app
# Expose any necessary ports (adjust as needed)
EXPOSE 8080

# Command to run the application
# Replace with the actual command to start the application
CMD ["java", "-jar", "/app/debridav-0.1.0.jar"]
