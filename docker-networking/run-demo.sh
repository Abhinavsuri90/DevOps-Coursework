#!/usr/bin/env bash
# Docker networking & volume demo (Session 8)
# Student: Abhinav
#
# Runs every task for real and prints each command before its output:
#   bash run-demo.sh 2>&1 | tee evidence/docker-networking-output.txt
# Optional: SNAPSHOT_HOOK=<command> is called with "before"/"after" around the live edit.
set -uo pipefail

cd "$(dirname "$0")"
HTML_DIR="$PWD/html-data"

run() {
  printf '$ %s\n' "$*"
  local out rc
  out=$(eval "$*" 2>&1); rc=$?
  [ -n "$out" ] && printf '%s\n' "$out"
  [ $rc -ne 0 ] && echo "(exit code $rc)"
  return 0
}
note() { printf '# %s\n' "$*"; }

cleanup() {
  docker rm -f frontend backend database apache-host bind-nginx >/dev/null 2>&1
  docker network rm frontend-net app-net database-net >/dev/null 2>&1
}
cleanup

note "Task 1 - three containers on three user-defined bridge networks"
run docker network create frontend-net
run docker network create app-net
run docker network create database-net
run docker run -d --name frontend --network frontend-net nginx:alpine
run docker run -d --name backend --network app-net nginx:alpine
run docker run -d --name database --network database-net -e MYSQL_RANDOM_ROOT_PASSWORD=yes mysql:8.0
note "Add the backend to a second network so it can reach the database"
run docker network connect database-net backend
run "docker inspect backend --format '{{range \$net, \$cfg := .NetworkSettings.Networks}}{{\$net}}={{\$cfg.IPAddress}} {{end}}'"
note "Wait for MySQL to accept connections on 3306"
for _ in $(seq 1 60); do
  docker exec backend nc -z -w 2 database 3306 >/dev/null 2>&1 && break
  sleep 2
done
note "Connectivity: backend <-> database share database-net"
run docker exec backend ping -c 2 database
run docker exec backend nc -zv -w 3 database 3306
note "Connectivity: frontend has no shared network with backend or database yet"
run docker exec frontend ping -c 2 -W 2 backend
run docker exec frontend ping -c 2 -W 2 database
note "Connect the frontend to app-net, then frontend -> backend works; frontend -> database stays isolated"
run docker network connect app-net frontend
run docker exec frontend ping -c 2 backend
run "docker exec frontend wget -qO- http://backend | grep -o '<title>.*</title>'"
run docker exec frontend ping -c 2 -W 2 database
note "Who is on which network"
for net in frontend-net app-net database-net; do
  run "docker network inspect $net --format '{{.Name}} ({{range .IPAM.Config}}{{.Subnet}}{{end}}): {{range .Containers}}{{.Name}} {{end}}'"
done

note "Task 2 - Apache2 (official httpd image) on the host network"
run docker run -d --name apache-host --network host httpd:2.4
sleep 3
run "docker inspect apache-host --format 'NetworkMode={{.HostConfig.NetworkMode}} PortBindings={{json .HostConfig.PortBindings}}'"
note "No -p mapping: Apache binds port 80 directly in the Docker host's network namespace"
run "docker run --rm --network host alpine:3.20 wget -qO- http://localhost:80"
note "From macOS itself (Docker Desktop runs the Docker host inside a VM)"
run curl -s -m 5 http://localhost:80

note "Task 3 - bind mount html-data/ into nginx"
run cat html-data/index.html
run docker run -d --name bind-nginx -p 8090:80 -v "\"$HTML_DIR\":/usr/share/nginx/html:ro" nginx:alpine
sleep 2
run curl -s http://localhost:8090
run "docker inspect bind-nginx --format 'Started={{.State.StartedAt}} Restarts={{.RestartCount}}'"
[ -n "${SNAPSHOT_HOOK:-}" ] && "$SNAPSHOT_HOOK" before
note "Edit the file on the host while the container keeps running"
run "sed -i '' 's#<h1>Hello students</h1>#<h1>Hello students - updated live on the host!</h1>#' html-data/index.html"
run curl -s http://localhost:8090
run "docker inspect bind-nginx --format 'Started={{.State.StartedAt}} Restarts={{.RestartCount}}'"
[ -n "${SNAPSHOT_HOOK:-}" ] && "$SNAPSHOT_HOOK" after
exit 0
