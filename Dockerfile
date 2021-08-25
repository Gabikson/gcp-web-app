FROM openjdk:latest

COPY ["target/cloudx-associate-gcp-demo-0.0.1.jar", "cloudx-associate-gcp-demo-0.0.1.jar"]

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "cloudx-associate-gcp-demo-0.0.1.jar"]