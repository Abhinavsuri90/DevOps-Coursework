# Docker Networking and Volumes

Student: **Abhinav**

This module documents multi-container network isolation, host network mode deployment, live bind mounting, and multi-host overlay networks. Commands and workflows are automated in [`run-demo.sh`](run-demo.sh).

## 1. Task 1: 3-Container Network Topology

```text
coursework-frontend ── frontend-net
        │
      app-net
        │
coursework-backend
        │
   database-net
        │
coursework-database
```

- **Frontend Container (`coursework-frontend`):** Attached to `frontend-net` and `app-net`.
- **Backend Container (`coursework-backend`):** Attached to `app-net` and `database-net`.
- **Database Container (`coursework-database`):** Attached strictly to `database-net`.

### Network Connectivity Matrix

| Source Container | Destination Container | Network Path | Connectivity Result | Reason |
| --- | --- | --- | --- | --- |
| `coursework-frontend` | `coursework-backend` | `app-net` | **CONNECTED** (Success) | Shared network segment with embedded DNS. |
| `coursework-backend` | `coursework-database` | `database-net` | **CONNECTED** (Success) | Shared network segment. |
| `coursework-frontend` | `coursework-database` | None | **ISOLATED** (Failed) | No shared network; security isolation enforced. |

```bash
docker network create frontend-net
docker network create app-net
docker network create database-net

docker run -d --name coursework-frontend --network frontend-net alpine sleep 3600
docker run -d --name coursework-backend --network app-net alpine sleep 3600
docker run -d --name coursework-database --network database-net -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

docker network connect database-net coursework-backend
docker network connect app-net coursework-frontend
```

---

## 2. Task 2: Host Network Mode

In host network mode (`--network host`), the container shares the host machine's network namespace directly, bypassing Docker's virtual bridge and port mapping NAT rules.

```bash
docker run -d --name coursework-host-apache --network host httpd:2.4-alpine
curl --fail http://localhost:80
```

*Key Insight:* In `--network host` mode, no port publishing (`-p host:container`) is required because the service binds directly to host port 80.

---

## 3. Task 3: Bind Mount Dynamic Content Test

A directory [`html-data`](html-data/) containing `index.html` with initial text **Hello students** was created on the local filesystem and bind-mounted into an Nginx container.

```bash
# Initial mount and verification
docker run -d --name coursework-bind-nginx -p 8090:80 -v $(pwd)/html-data:/usr/share/nginx/html:ro nginx:alpine
curl http://localhost:8090
```

Response:
```html
<h1>Hello students</h1>
```

Modifying `html-data/index.html` live on the host filesystem:

```bash
echo "<h1>Hello students - Updated live!</h1>" > html-data/index.html
curl http://localhost:8090
```

Updated Response (without container restart):
```html
<h1>Hello students - Updated live!</h1>
```

---

## 4. Task 4: Overlay Networks Research

### What is an Overlay Network?
An **overlay network** is a distributed network spanning across multiple Docker daemon hosts in a cluster (Docker Swarm cluster). It enables containers running on separate physical or virtual machines to communicate securely over an encrypted VXLAN tunnel as if they were residing on the exact same local layer-2 subnet.

### Key Use Cases
- Multi-host microservices architectures.
- Dynamic service discovery and routing in Docker Swarm stacks.
- Secure cross-host container communication with automatic IPSec data encryption (`--opt encrypted`).

### Required Network Ports
- **TCP 2377:** Cluster management & control plane communications.
- **TCP/UDP 7946:** Node-to-node gossip network discovery.
- **UDP 4789:** Data plane VXLAN overlay traffic encapsulation.

*In an interview I'd say:* Overlay networks encapsulate cross-host container traffic inside VXLAN tunnels across a Docker Swarm cluster, enabling seamless microservice discovery and communication across separate physical servers.
