from datetime import date
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

Category = Literal["food", "travel", "books", "rent", "fun", "other"]


class ExpenseIn(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    amount: Decimal = Field(gt=0, max_digits=10, decimal_places=2)
    category: Category
    spent_on: date
    notes: str | None = Field(default=None, max_length=300)


class ExpenseOut(ExpenseIn):
    model_config = ConfigDict(from_attributes=True)

    id: int


class CategoryTotal(BaseModel):
    category: str
    total: Decimal
    count: int


class Summary(BaseModel):
    total: Decimal
    count: int
    by_category: list[CategoryTotal]
