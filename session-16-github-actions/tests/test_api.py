import pytest

from app import create_app


@pytest.fixture()
def client():
    return create_app().test_client()


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"


def test_grade_scale(client):
    body = client.get("/api/grades").get_json()
    assert body["scale"] == "4.0"
    assert body["grade_points"]["A-"] == 3.7


def test_gpa_endpoint(client):
    response = client.post("/api/gpa", json={"courses": [{"credits": 4, "grade": "A"}, {"credits": 4, "grade": "B+"}]})
    assert response.status_code == 200
    assert response.get_json() == {"gpa": 3.65, "total_credits": 8}


def test_gpa_endpoint_validation(client):
    response = client.post("/api/gpa", json={"courses": [{"credits": 4, "grade": "E"}]})
    assert response.status_code == 400
    assert "unknown grade" in response.get_json()["error"]
