# Docker Fundamentals

Student: **Abhinav**

This module contains six isolated Hello World applications with custom `Dockerfile` specifications built for Node.js, Python, Java, Apache, React, and Nginx.

## 1. Application Directory Matrix

| Application | Folder | Container Port | Build Command | Expected Output |
| --- | --- | ---: | --- | --- |
| Node.js | [`nodejs-app`](nodejs-app/) | 3000 | `docker build -t coursework-nodejs ./nodejs-app` | Hello World from Node.js! |
| Python/Flask | [`python-app`](python-app/) | 5000 | `docker build -t coursework-python ./python-app` | Hello World from Python! |
| Java | [`java-app`](java-app/) | 8080 | `docker build -t coursework-java ./java-app` | Hello World from Java! |
| Apache | [`Apache-app`](Apache-app/) | 80 | `docker build -t coursework-apache ./Apache-app` | Hello World from Apache! |
| React | [`React-app`](React-app/) | 80 | `docker build -t coursework-react ./React-app` | Hello World from React! |
| Nginx | [`nginx-app`](nginx-app/) | 80 | `docker build -t coursework-nginx ./nginx-app` | Hello World from Nginx! |

## 2. Build, Container Run, and HTTP Verification Commands

```bash
# 1. Node.js Application
docker build -t coursework-nodejs ./nodejs-app
docker run -d --name nodejs-hello -p 3001:3000 coursework-nodejs
curl --fail http://localhost:3001

# 2. Python/Flask Application
docker build -t coursework-python ./python-app
docker run -d --name python-hello -p 5001:5000 coursework-python
curl --fail http://localhost:5001

# 3. Java Application
docker build -t coursework-java ./java-app
docker run -d --name java-hello -p 8081:8080 coursework-java
curl --fail http://localhost:8081

# 4. Apache Application
docker build -t coursework-apache ./Apache-app
docker run -d --name apache-hello -p 8082:80 coursework-apache
curl --fail http://localhost:8082

# 5. React Application
docker build -t coursework-react ./React-app
docker run -d --name react-hello -p 8083:80 coursework-react
curl --fail http://localhost:8083

# 6. Nginx Application
docker build -t coursework-nginx ./nginx-app
docker run -d --name nginx-hello -p 8084:80 coursework-nginx
curl --fail http://localhost:8084
```

## 3. Real Captured Execution Response

```
ERROR: failed to connect to the docker API at unix:///Users/abhinavsuri/.docker/run/docker.sock; check if the path is correct and if the daemon is running
```

*(Note: When Docker Desktop / Docker daemon is started on the host or executed inside Linux containers/Codespaces, each `docker build` packages the source code into image layers, `docker run -d` starts background containers, and `-p host:container` routes network traffic to display the Hello World responses).*

## 4. Key Takeaways

- **Container Isolation:** Each application stack runs in its own isolated filesystem and network namespace without port conflicts on host interfaces.
- **Port Mapping (`-p host:container`):** Maps a host machine port to the exposed container port (e.g., `-p 3001:3000`).
- **Base Images:** Custom applications leverage minimal base images (`alpine`, `python-slim`, `openjdk-alpine`, `httpd-alpine`) to optimize container footprint.
