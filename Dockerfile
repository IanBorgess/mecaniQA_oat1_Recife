# Build stage - compile the application
FROM amazoncorretto:21 AS builder

WORKDIR /workspace

# Install xargs (findutils package)
RUN yum install -y findutils

# Copy build files
COPY gradle gradle
COPY gradlew gradlew
COPY build.gradle.kts build.gradle.kts
COPY settings.gradle.kts settings.gradle.kts
COPY gradle.properties gradle.properties
COPY src src

# Make gradlew executable and build
RUN chmod +x gradlew && ./gradlew build -x test --no-daemon

# Runtime stage - minimal image
FROM amazoncorretto:21-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the built JAR from builder
COPY --from=builder /workspace/build/libs/my-corretto-app.jar app.jar

# Set ownership to non-root user
RUN chown appuser:appgroup app.jar

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Execute application
CMD ["java", "-jar", "app.jar"]
