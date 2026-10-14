#!/usr/bin/env bash
# Small Prometheus / Alertmanager API helper for SpendWise (both port-forwarded to localhost).
# Usage: bash monitoring/prom.sh targets            # SpendWise scrape targets: health and last scrape error
#        bash monitoring/prom.sh alerts             # SpendWise alerts in Prometheus: pending / firing
#        bash monitoring/prom.sh am                 # SpendWise alerts that reached Alertmanager
#        bash monitoring/prom.sh query '<PromQL>'   # instant query, "labels => value" per series
set -euo pipefail
PROM_URL="${PROM_URL:-http://localhost:9090}"
AM_URL="${AM_URL:-http://localhost:9093}"

case "${1:-}" in
  targets)
    curl -s "$PROM_URL/api/v1/targets?state=active" | python3 -c '
import json, sys
targets = [t for t in json.load(sys.stdin)["data"]["activeTargets"] if t["labels"].get("namespace") == "spendwise"]
for t in targets:
    line = [t["labels"]["job"], t["labels"]["pod"], t["scrapeUrl"], "health=" + t["health"]]
    if t["lastError"]:
        line.append("error=" + repr(t["lastError"]))
    print(*line)
if not targets:
    print("(no spendwise targets)")
'
    ;;
  alerts)
    curl -s "$PROM_URL/api/v1/alerts" | python3 -c '
import json, sys
alerts = [a for a in json.load(sys.stdin)["data"]["alerts"] if a["labels"].get("app") == "spendwise"]
for a in alerts:
    print(a["labels"]["alertname"], "severity=" + a["labels"].get("severity", ""), "state=" + a["state"], "activeAt=" + a["activeAt"])
if not alerts:
    print("(no spendwise alerts pending or firing)")
'
    ;;
  am)
    curl -s "$AM_URL/api/v2/alerts?filter=app=%22spendwise%22" | python3 -c '
import json, sys
alerts = json.load(sys.stdin)
for a in alerts:
    print(a["labels"]["alertname"], "severity=" + a["labels"].get("severity", ""), "state=" + a["status"]["state"], "since=" + a["startsAt"])
if not alerts:
    print("(no spendwise alerts in Alertmanager)")
'
    ;;
  query)
    curl -s "$PROM_URL/api/v1/query" --data-urlencode "query=$2" | python3 -c '
import json, sys
data = json.load(sys.stdin)
if data.get("status") != "success":
    sys.exit(data.get("error", "query failed"))
keep = ("pod", "job", "status", "route", "method", "category", "alertname", "horizontalpodautoscaler")
for series in data["data"]["result"]:
    labels = " ".join(f"{k}={v}" for k, v in series["metric"].items() if k in keep) or "{}"
    print(labels, "=>", series["value"][1])
if not data["data"]["result"]:
    print("(no data)")
'
    ;;
  *)
    echo "usage: $0 targets | alerts | am | query '<PromQL>'" >&2
    exit 2
    ;;
esac
