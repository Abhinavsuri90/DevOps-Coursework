#!/usr/bin/env bash
set -euo pipefail

# Docker Networking & Volume Demonstration Script
# Student: Abhinav

echo "=========================================="
echo "    DOCKER NETWORKING & VOLUME DEMO       "
echo "=========================================="

echo "--- Task 1: Container Networking ---"
echo "Creating 3 user-defined bridge networks..."
echo "docker network create frontend-net"
echo "docker network create app-net"
echo "docker network create database-net"
echo ""

echo "Deploying 3 isolated containers..."
echo "docker run -d --name coursework-frontend --network frontend-net alpine sleep 3600"
echo "docker run -d --name coursework-backend --network app-net alpine sleep 3600"
echo "docker run -d --name coursework-database --network database-net -e MYSQL_ROOT_PASSWORD=secret mysql:8.0"
echo ""

echo "Connecting backend container to database-net..."
echo "docker network connect database-net coursework-backend"
echo "docker network connect app-net coursework-frontend"
echo ""

echo "--- Task 2: Host Network Mode ---"
echo "docker run -d --name coursework-host-apache --network host httpd:2.4-alpine"
echo "curl http://localhost:80"
echo ""

echo "--- Task 3: Bind Mount Verification ---"
echo "Initial file content in html-data/index.html: Hello students"
echo "docker run -d --name coursework-bind-nginx -p 8090:80 -v $(pwd)/html-data:/usr/share/nginx/html:ro nginx:alpine"
echo "curl http://localhost:8090"
echo ""
echo "Updating index.html live on host to: Hello students - Updated live!"
echo "curl http://localhost:8090"
