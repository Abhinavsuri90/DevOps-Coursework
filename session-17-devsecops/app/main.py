"""Campus Library API (Session 17 DevSecOps demo)."""

import os
from threading import Lock

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="Campus Library API", version=os.environ.get("APP_VERSION", "dev"))


class BookIn(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    author: str = Field(min_length=1, max_length=120)


class Book(BookIn):
    id: int
    available: bool = True


_books: dict[int, Book] = {}
_lock = Lock()


def _seed() -> None:
    _books.clear()
    for title, author in [("Clean Code", "Robert C. Martin"), ("The Phoenix Project", "Gene Kim")]:
        book_id = len(_books) + 1
        _books[book_id] = Book(id=book_id, title=title, author=author)


_seed()


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "version": app.version}


@app.get("/books")
def list_books() -> list[Book]:
    return list(_books.values())


@app.get("/books/{book_id}")
def get_book(book_id: int) -> Book:
    if book_id not in _books:
        raise HTTPException(status_code=404, detail="book not found")
    return _books[book_id]


@app.post("/books", status_code=201)
def add_book(book: BookIn) -> Book:
    with _lock:
        new = Book(id=max(_books, default=0) + 1, **book.model_dump())
        _books[new.id] = new
    return new


@app.post("/books/{book_id}/borrow")
def borrow_book(book_id: int) -> Book:
    book = get_book(book_id)
    if not book.available:
        raise HTTPException(status_code=409, detail="book already borrowed")
    book.available = False
    return book


@app.post("/books/{book_id}/return")
def return_book(book_id: int) -> Book:
    book = get_book(book_id)
    book.available = True
    return book
