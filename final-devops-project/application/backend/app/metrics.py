"""Prometheus metrics for the API."""

import time

from prometheus_client import Counter, Histogram
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

REQUESTS = Counter(
    "spendwise_http_requests_total", "HTTP requests handled", ["method", "route", "status"]
)
LATENCY = Histogram(
    "spendwise_http_request_duration_seconds", "HTTP request latency", ["method", "route"]
)
EXPENSES_CREATED = Counter(
    "spendwise_expenses_created_total", "Expenses created", ["category"]
)


class MetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = time.perf_counter()
        response = await call_next(request)
        route = request.scope.get("route")
        # Use the route template (e.g. /api/expenses/{expense_id}) to keep label cardinality low.
        path = route.path if route is not None else "unmatched"
        if path != "/metrics":
            REQUESTS.labels(request.method, path, str(response.status_code)).inc()
            LATENCY.labels(request.method, path).observe(time.perf_counter() - start)
        return response
