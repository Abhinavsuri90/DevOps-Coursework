# Observability: Metrics, Logs and Traces

**Session 20 · Task 2** · Author: Abhinav (24BCS10282)

## Monitoring vs observability

| | Monitoring | Observability |
| --- | --- | --- |
| Question | "Is it working?" (known failure modes) | "Why is it behaving like this?" (including unknown failure modes) |
| Approach | Predefined checks, dashboards and thresholds | Rich telemetry you can slice, correlate and query after the fact |
| Example | Alert when error rate > 10% | From that alert, find which endpoint, Pod, version and downstream call caused it |

Monitoring is part of observability. A system is *observable* when its outputs (telemetry) let you explain its internal state without shipping new code to debug it.

## The three pillars

### 1. Metrics: "how much, how often, how fast"

Numeric time series with labels, cheap to store and fast to aggregate. Ideal for dashboards and alerts.

| Type | Meaning | Example from the [orders-service demo](../01-monitoring/orders-service.yaml) |
| --- | --- | --- |
| Counter | Only goes up | `orders_http_requests_total{path="/api/orders",status="500"}` |
| Gauge | Goes up and down | `orders_uptime_seconds`, `container_memory_working_set_bytes` |
| Histogram | Bucketed observations, for percentiles | `orders_http_request_duration_seconds_bucket{le="0.05"}` |

Useful signal sets:
- **Golden signals:** latency, traffic, errors, saturation.
- **RED** (for services): Rate, Errors, Duration.
- **USE** (for resources): Utilization, Saturation, Errors.

The PromQL used in this session:

```promql
sum(rate(orders_http_requests_total[1m]))                                           # traffic (req/s)
sum(rate(orders_http_requests_total{status=~"5.."}[1m])) / sum(rate(orders_http_requests_total[1m]))  # error ratio
histogram_quantile(0.95, sum by (le) (rate(orders_http_request_duration_seconds_bucket[5m])))          # p95 latency
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="observability",container="app"}[2m]))  # CPU cores
sum by (pod) (container_memory_working_set_bytes{namespace="observability",container="app"})          # memory
```

### 2. Logs: "what exactly happened"

Timestamped records of discrete events, with full detail (IDs, messages, stack traces). They are expensive at volume, but irreplaceable for root cause. **Structured (JSON) logs** can be filtered by field. The demo service writes one JSON line per request, for example:

```json
{"ts": "…", "level": "error", "pod": "orders-service-…", "path": "/api/orders", "status": 500, "duration_ms": 41.2}
```

In Kubernetes, containers log to stdout/stderr. The kubelet stores those streams per container, `kubectl logs` reads them, and a node agent (Fluent Bit, Promtail/Alloy, Vector) ships them to a backend.

### 3. Traces: "where did the time go"

A **trace** follows one request across services. Each hop is a **span** with start time, duration, attributes and a parent span ID. A shared **trace ID**, propagated in headers (W3C `traceparent`), stitches them together.

```text
trace 4bf92f35…  POST /checkout                                 820 ms
├── span  frontend  render                                       30 ms
├── span  orders-service  /api/orders                           610 ms
│   ├── span  postgres  SELECT orders                            25 ms
│   └── span  payment-gateway  POST /charge                     560 ms  ← the slow part
└── span  notification  send email                                40 ms
```

Metrics tell you p95 latency went up, logs tell you which requests failed, and traces show *which hop* caused the delay. Exemplars and a shared trace ID in logs connect the three.

## Why observability is required

- **Distributed systems fail in new ways.** With dozens of services, Pods that come and go, and network hops, you can't predict every failure in advance.
- **Faster detection and recovery (MTTD/MTTR).** Alerts notice problems before users report them, and correlated telemetry shortens the investigation.
- **SLOs and error budgets** need measured availability and latency.
- **Capacity and cost:** right-size requests and limits and HPA targets from real CPU and memory data (Session 13).
- **Safe delivery:** compare metrics before and after a rollout, and roll back on regressions (Sessions 10 and 15).

## Common tools

| Pillar | Open source | Managed / commercial |
| --- | --- | --- |
| Metrics | **Prometheus**, Thanos, Mimir, VictoriaMetrics | Amazon Managed Prometheus, CloudWatch, Datadog |
| Dashboards | **Grafana** | Grafana Cloud, CloudWatch dashboards |
| Alerting | **Alertmanager**, Grafana Alerting | PagerDuty, Opsgenie |
| Logs | Loki, Elasticsearch/OpenSearch + Fluent Bit (EFK), Vector | CloudWatch Logs, Splunk, Datadog Logs |
| Traces | **OpenTelemetry** (instrumentation and Collector), Jaeger, Tempo, Zipkin | AWS X-Ray, Datadog APM, Honeycomb |
| All-in-one standard | **OpenTelemetry** (metrics, logs and traces SDKs plus the OTLP protocol) | — |

## Kubernetes observability

| Layer | Where the data comes from | What this session used |
| --- | --- | --- |
| Cluster state | **kube-state-metrics**: Deployments, Pods, replicas, restarts, readiness | `kube_pod_container_status_ready`, `kube_deployment_status_replicas_available` |
| Node | **node-exporter**: CPU, memory, disk, network of each node | Node CPU/memory dashboards |
| Containers | **cAdvisor** in the kubelet | `container_cpu_usage_seconds_total`, `container_memory_working_set_bytes` |
| Live resource view | **metrics-server**, used by `kubectl top` and the HPA | `kubectl top pods -n observability` |
| Applications | App `/metrics` endpoints scraped through **ServiceMonitor**s | `orders_http_requests_total`, latency histogram |
| Events | Kubernetes Events (`kubectl events`) | Probe failures, scheduling, OOMKilled (Session 14) |
| Logs | Container stdout/stderr via `kubectl logs`, or a log agent DaemonSet | Structured JSON logs from orders-service |
| Health | Liveness/readiness/startup probes plus Prometheus `up` | `/healthz` probes, `up{job="orders-service"}` |

The **kube-prometheus-stack** Helm chart (installed in [Task 1](../README.md#task-1-monitoring)) bundles the Prometheus Operator, Prometheus, Alertmanager, Grafana with built-in Kubernetes dashboards, kube-state-metrics and node-exporter. Applications opt in to scraping with a `ServiceMonitor`, and alert rules are added with a `PrometheusRule`. Both are custom resources, so monitoring is configured declaratively, like everything else in Kubernetes.
