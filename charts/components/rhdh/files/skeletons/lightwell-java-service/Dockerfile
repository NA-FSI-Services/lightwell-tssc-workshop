# UBI-based runtime for workshop demos (Hummingbird stretch is optional / separate issues)
FROM registry.access.redhat.com/ubi9/openjdk-17:1.21

ENV LANGUAGE='en_US:en'

COPY --chown=185 target/*-SNAPSHOT.jar /deployments/app.jar

EXPOSE 8080
USER 185
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"
ENTRYPOINT ["java", "-jar", "/deployments/app.jar"]
