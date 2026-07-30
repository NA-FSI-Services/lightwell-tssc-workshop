# Multi-stage build for spring-boot-lw-poc (Java 17)
FROM registry.access.redhat.com/ubi9/openjdk-17:1.21 AS build
USER root
WORKDIR /build
COPY pom.xml ./
COPY src ./src
# Image build uses Maven Central. Learners use settings.xml + LWN/Nexus profiles in the lab.
RUN mvn -B -DskipTests package

FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:1.21
WORKDIR /deployments
COPY --from=build /build/target/spring-boot-lw-poc-*.jar /deployments/app.jar
EXPOSE 8080
USER 185
ENTRYPOINT ["java", "-jar", "/deployments/app.jar"]
