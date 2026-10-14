LUNCH = {"title": "Canteen lunch", "amount": "120.50", "category": "food", "spent_on": "2026-10-10"}
BOOK = {"title": "DevOps Handbook", "amount": "899.00", "category": "books", "spent_on": "2026-10-11"}


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["database"] == "ok"


def test_create_and_list_expenses(client):
    created = client.post("/api/expenses", json=LUNCH)
    assert created.status_code == 201
    assert created.json()["id"] == 1
    assert created.json()["amount"] == "120.50"
    listed = client.get("/api/expenses").json()
    assert [item["title"] for item in listed] == ["Canteen lunch"]


def test_filter_by_category(client):
    client.post("/api/expenses", json=LUNCH)
    client.post("/api/expenses", json=BOOK)
    books = client.get("/api/expenses", params={"category": "books"}).json()
    assert [item["title"] for item in books] == ["DevOps Handbook"]


def test_list_returns_newest_first_up_to_limit(client):
    for day in range(1, 6):
        client.post("/api/expenses", json={**LUNCH, "spent_on": f"2026-10-0{day}"})
    newest = client.get("/api/expenses", params={"limit": 2}).json()
    assert [item["spent_on"] for item in newest] == ["2026-10-05", "2026-10-04"]
    assert len(client.get("/api/expenses").json()) == 5
    assert client.get("/api/expenses", params={"limit": 0}).status_code == 422
    assert client.get("/api/expenses", params={"limit": 501}).status_code == 422


def test_get_update_and_delete(client):
    expense_id = client.post("/api/expenses", json=LUNCH).json()["id"]
    assert client.get(f"/api/expenses/{expense_id}").json()["category"] == "food"
    updated = client.put(f"/api/expenses/{expense_id}", json={**LUNCH, "amount": "99.99"})
    assert updated.json()["amount"] == "99.99"
    assert client.delete(f"/api/expenses/{expense_id}").status_code == 204
    assert client.get(f"/api/expenses/{expense_id}").status_code == 404


def test_summary_totals_by_category(client):
    client.post("/api/expenses", json=LUNCH)
    client.post("/api/expenses", json=LUNCH)
    client.post("/api/expenses", json=BOOK)
    summary = client.get("/api/summary").json()
    assert summary["count"] == 3
    assert summary["total"] == "1140.00"
    assert summary["by_category"][0] == {"category": "books", "total": "899.00", "count": 1}


def test_validation_rejects_bad_input(client):
    assert client.post("/api/expenses", json={**LUNCH, "amount": "-5"}).status_code == 422
    assert client.post("/api/expenses", json={**LUNCH, "category": "casino"}).status_code == 422
    assert client.put("/api/expenses/999", json=LUNCH).status_code == 404


def test_metrics_endpoint(client):
    client.post("/api/expenses", json=LUNCH)
    body = client.get("/metrics").text
    assert "spendwise_http_requests_total" in body
    assert 'spendwise_expenses_created_total{category="food"}' in body
