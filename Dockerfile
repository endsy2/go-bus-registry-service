# ─── Stage 1: Build ─────────────────────────────
FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy entire project (IMPORTANT FIX)
COPY . .

# Build only Eureka service
RUN ./gradlew :eureka-server:build -x test --no-daemon


# ─── Stage 2: Runtime ───────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN apk add --no-cache curl

COPY --from=build /app/eureka-server/build/libs/*.jar app.jar

ENV PORT=8761
EXPOSE ${PORT}

ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -Xmx768m -Xms512m -jar app.jar"]