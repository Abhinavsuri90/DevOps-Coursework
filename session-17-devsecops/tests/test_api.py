import pytest
from fastapi.testclient import TestClient

from app import main


@pytest.fixture()
def client():
    main._seed()
    return TestClient(main.app)


def test_health(client):
    assert client.get("/health").json()["status"] == "ok"


def test_list_books(client):
    titles = [book["title"] for book in client.get("/books").json()]
    assert titles == ["Clean Code", "The Phoenix Project"]


def test_add_book(client):
    response = client.post("/books", json={"title": "Accelerate", "author": "Nicole Forsgren"})
    assert response.status_code == 201
    assert response.json() == {"id": 3, "title": "Accelerate", "author": "Nicole Forsgren", "available": True}


def test_add_book_validation(client):
    assert client.post("/books", json={"title": "", "author": "x"}).status_code == 422


def test_borrow_and_return(client):
    assert client.post("/books/1/borrow").json()["available"] is False
    assert client.post("/books/1/borrow").status_code == 409
    assert client.post("/books/1/return").json()["available"] is True


def test_missing_book(client):
    assert client.get("/books/99").status_code == 404
