#!/usr/bin/env bash
# List active alerts for team=orders from Prometheus (and, with "am", from Alertmanager).
# Usage: bash alerts.sh        # Prometheus rule state: pending / firing
#        bash alerts.sh am     # what Alertmanager received
set -euo pipefail
if [ "${1:-}" = "am" ]; then
  curl -s "${AM_URL:-http://localhost:9093}/api/v2/alerts?filter=team=%22orders%22" | python3 -c '
import json, sys
alerts = json.load(sys.stdin)
for a in alerts:
    print(a["labels"]["alertname"], "severity=" + a["labels"].get("severity", ""), "state=" + a["status"]["state"], "since=" + a["startsAt"])
if not alerts:
    print("(no orders alerts in Alertmanager)")
'
else
  curl -s "${PROM_URL:-http://localhost:9090}/api/v1/alerts" | python3 -c '
import json, sys
alerts = [a for a in json.load(sys.stdin)["data"]["alerts"] if a["labels"].get("team") == "orders"]
for a in alerts:
    print(a["labels"]["alertname"], "state=" + a["state"], "activeAt=" + a["activeAt"], "value=" + a["value"])
if not alerts:
    print("(no orders alerts pending or firing)")
'
fi
