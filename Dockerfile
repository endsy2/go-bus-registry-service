# ─── Stage 1: Build ───────────────────────────────────────────────────────────
FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy gradle wrapper and root build files from backend directory
COPY /gradlew gradlew
COPY /gradle gradle
COPY /build.gradle build.gradle
COPY /settings.gradle settings.gradle

# Copy eureka-server specific files
COPY /eureka-server/build.gradle eureka-server/build.gradle
COPY /eureka-server/src eureka-server/src

# Build the service
RUN ./gradlew :eureka-server:build -x test --no-daemon

# ─── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN apk add --no-cache curl

COPY --from=build /app/eureka-server/build/libs/*.jar app.jar

# Railway provides PORT environment variable
ENV PORT=8761

EXPOSE ${PORT}

# Use Railway's PORT variable and set memory limits
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -Xmx768m -Xms512m -jar app.jar"]
