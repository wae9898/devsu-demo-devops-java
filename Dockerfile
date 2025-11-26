# ====== STAGE 1 - Build ======
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn -q -e -B dependency:go-offline

COPY src ./src
RUN mvn -q -e -B -DskipTests package

# ====== STAGE 2 - Runtime ======
FROM eclipse-temurin:17-jre-alpine

ENV APP_HOME=/app
WORKDIR $APP_HOME

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Healthcheck contra Spring Boot actuator
HEALTHCHECK --interval=20s --timeout=3s \
  CMD wget -qO- http://localhost:${PORT}/api/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java -jar app.jar"]