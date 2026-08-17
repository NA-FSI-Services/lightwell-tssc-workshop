# V2-13 incomplete seed — Track 3 starts on UBI (wrong product).
# Replace the runtime FROM with the mirrored Hummingbird digest: dest_registry_host
# from demo-userinfo-lightwell-repo plus the digest in hummingbird_source_pullspec.
# Do not copy a sample FROM from Showroom (Check fails). Do not put hi/openjdk here.
# Image build uses Maven Central inside the Dockerfile; learner LW_* Secret is for local mvn only.
FROM registry.access.redhat.com/ubi9/openjdk-21:1.21 AS build
USER root
WORKDIR /build
COPY pom.xml ./
COPY src ./src
RUN mvn -B -DskipTests -Dcommons.lang3.version=3.14.0 package

FROM registry.access.redhat.com/ubi9/openjdk-21-runtime:1.21
WORKDIR /deployments
COPY --from=build /build/target/*-SNAPSHOT.jar /deployments/app.jar
EXPOSE 8080
USER 185
ENTRYPOINT ["java", "-jar", "/deployments/app.jar"]
