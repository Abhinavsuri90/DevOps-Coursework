FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /src
COPY HelloWorld.java ./
RUN javac HelloWorld.java

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /src/HelloWorld.class ./
EXPOSE 8080
CMD ["java", "HelloWorld"]
