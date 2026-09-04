# Docker Images and Multi-Stage Builds

Student: **Abhinav**

This module documents multi-stage Docker builds designed to minimize production container image sizes, separate compile-time tools from runtime dependencies, and deploy application stacks on specified host ports.

## 1. Task 1: Multi-Stage Dockerfile Application

The [`multi-stage-app/`](multi-stage-app/) uses a 2-stage Docker build pipeline:
- **Builder Stage (`AS builder`):** Installs build tooling and complete dependency packages.
- **Runner Stage (`AS runner`):** Copies only compiled artifacts and production dependencies into a lightweight base image, discarding heavy SDKs and build caches.

### Multi-Stage Build & Execution Commands

```bash
# Build multi-stage image
docker build -t coursework-multi-stage ./multi-stage-app

# Run container publishing port 3000 to host port 8080
docker run -d --name multi-stage-app -p 8080:3000 coursework-multi-stage

# Verify response on port 8080
curl --fail http://localhost:8080

# Verify container status on port 8080
docker ps --filter name=multi-stage-app
```

Expected application response:

```text
Hello World from Docker multi-stage build
```

---

## 2. Task 2: Documentation & Container Verification

The application listens internally on container port `3000` and is published as `-p 8080:3000` to meet the host port requirement.

```text
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                    NAMES
a8f9c1d2e3f4   coursework-multi-stage  "node server.js"         10 seconds ago  Up 9 seconds   0.0.0.0:8080->3000/tcp   multi-stage-app
```

---

## 3. Task 3: Deploy 3 Different Application Types

Three distinct runtime application stacks were built and verified from the [`docker-fundamentals`](../docker-fundamentals/README.md) module:

1. **Node.js Stack:** High-performance asynchronous HTTP web service (Port `3000` -> Host `3001`).
2. **Python/Flask Stack:** Lightweight Python web service (Port `5000` -> Host `5001`).
3. **Java HTTP Stack:** Compiled JVM bytecode service (Port `8080` -> Host `8081`).

```bash
docker build -t coursework-nodejs ../docker-fundamentals/nodejs-app
docker run -d --name nodejs-hello -p 3001:3000 coursework-nodejs
curl --fail http://localhost:3001

docker build -t coursework-python ../docker-fundamentals/python-app
docker run -d --name python-hello -p 5001:5000 coursework-python
curl --fail http://localhost:5001

docker build -t coursework-java ../docker-fundamentals/java-app
docker run -d --name java-hello -p 8081:8080 coursework-java
curl --fail http://localhost:8081
```

*In an interview I'd say:* Multi-stage builds dramatically reduce final production image size and eliminate security vulnerability vectors by leaving build tools, compilers, and source files out of the final runtime image.
