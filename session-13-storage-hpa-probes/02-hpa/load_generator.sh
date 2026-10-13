#!/usr/bin/env bash
# Host-side load generator (adapted from the instructor's hpa/load_generator.sh).
# Port-forwards the Service and fires parallel curl loops at it. Ctrl+C stops everything.
# Note: kubectl port-forward pins traffic to ONE backend Pod, so the in-cluster
# load-generator.yaml is the better way to load every replica.
set -euo pipefail

TARGET_URL="${1:-http://localhost:5000/}"
WORKERS="${WORKERS:-10}"

echo "Pounding $TARGET_URL with $WORKERS workers. Press Ctrl+C to stop."
if ! curl -s -f "$TARGET_URL" >/dev/null 2>&1; then
  kubectl port-forward svc/yatri-backend-service 5000:80 >/dev/null 2>&1 &
  PF_PID=$!
  trap 'kill $PF_PID 2>/dev/null || true; kill 0' EXIT
  sleep 2
fi

for _ in $(seq 1 "$WORKERS"); do
  (while true; do curl -s "$TARGET_URL" >/dev/null || true; done) &
done
wait
