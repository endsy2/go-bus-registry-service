# ─── Stage 1: Build ─────────────────────────────
FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy entire project
COPY . .

# FIX: ensure gradlew is executable
RUN chmod +x gradlew

# Build the application
RUN ./gradlew build -x test --no-daemon


# ─── Stage 2: Runtime ───────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN apk add --no-cache curl

# Copy built jar
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8761

ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8761} -Xmx768m -Xms512m -jar app.jar"]