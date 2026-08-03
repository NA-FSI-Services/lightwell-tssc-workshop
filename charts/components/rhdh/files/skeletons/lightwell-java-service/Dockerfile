# Multi-stage build (optional RHDH path) — matches Gitea-seeded PoC BuildConfig strategy.
# Image build uses Maven Central inside the Dockerfile; learner LW_* Secret is for local mvn only.
FROM registry.access.redhat.com/ubi9/openjdk-17:1.21 AS build
USER root
WORKDIR /build
COPY pom.xml ./
COPY src ./src
RUN mvn -B -DskipTests package

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.21
WORKDIR /deployments
COPY --from=build /build/target/*-SNAPSHOT.jar /deployments/app.jar
EXPOSE 8080
USER 185
ENTRYPOINT ["java", "-jar", "/deployments/app.jar"]
