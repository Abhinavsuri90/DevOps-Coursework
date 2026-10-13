#!/usr/bin/env bash
# Run a PromQL instant query against Prometheus (port-forwarded to localhost:9090)
# and print "labels => value" per series.
# Usage: bash promql.sh 'sum(rate(orders_http_requests_total[1m]))'
set -euo pipefail
curl -s "${PROM_URL:-http://localhost:9090}/api/v1/query" --data-urlencode "query=$1" | python3 -c '
import json, sys
data = json.load(sys.stdin)
if data.get("status") != "success":
    sys.exit(data.get("error", "query failed"))
keep = ("pod", "status", "job", "path", "alertname", "deployment")
for series in data["data"]["result"]:
    labels = " ".join(f"{k}={v}" for k, v in series["metric"].items() if k in keep) or "{}"
    print(labels, "=>", series["value"][1])
if not data["data"]["result"]:
    print("(no data)")
'
