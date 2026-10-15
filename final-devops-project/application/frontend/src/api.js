// All calls are relative, so they work behind nginx (Docker Compose) and the Ingress (Kubernetes).
async function request(path, options = {}) {
  const response = await fetch(`/api${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.detail ? JSON.stringify(body.detail) : `HTTP ${response.status}`);
  }
  return response.status === 204 ? null : response.json();
}

export const api = {
  list: (category) => request(category ? `/expenses?category=${category}` : "/expenses"),
  summary: () => request("/summary"),
  version: () => request("/version"),
  create: (expense) => request("/expenses", { method: "POST", body: JSON.stringify(expense) }),
  remove: (id) => request(`/expenses/${id}`, { method: "DELETE" }),
};
