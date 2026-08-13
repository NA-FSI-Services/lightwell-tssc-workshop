# Multi-stage build for spring-boot-lw-poc (Java 17)
# Image build uses Maven Central. Override commons.lang3.version so a learner
# .rhlw-* default pin (Module 5 dep-gate) does not break Docker package resolution.
# Learners use settings.xml + LWN/Nexus profiles for local Maven (not this Dockerfile).
FROM registry.access.redhat.com/ubi9/openjdk-17:1.21 AS build
USER root
WORKDIR /build
COPY pom.xml ./
COPY src ./src
RUN mvn -B -DskipTests -Dcommons.lang3.version=3.14.0 package

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.21
WORKDIR /deployments
COPY --from=build /build/target/spring-boot-lw-poc-*.jar /deployments/app.jar
EXPOSE 8080
USER 185
ENTRYPOINT ["java", "-jar", "/deployments/app.jar"]
