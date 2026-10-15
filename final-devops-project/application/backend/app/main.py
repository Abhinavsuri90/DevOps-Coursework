"""SpendWise API - track student expenses."""

from decimal import Decimal

from fastapi import Depends, FastAPI, HTTPException, Query, Response
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from app.config import APP_VERSION
from app.db import get_db
from app.metrics import EXPENSES_CREATED, MetricsMiddleware
from app.models import Expense
from app.schemas import CategoryTotal, ExpenseIn, ExpenseOut, Summary

app = FastAPI(title="SpendWise API", version=APP_VERSION)
app.add_middleware(MetricsMiddleware)


def _get_or_404(db: Session, expense_id: int) -> Expense:
    expense = db.get(Expense, expense_id)
    if expense is None:
        raise HTTPException(status_code=404, detail="expense not found")
    return expense


@app.get("/health")
def health(db: Session = Depends(get_db)) -> dict:
    db.execute(text("SELECT 1"))
    return {"status": "ok", "database": "ok", "version": APP_VERSION}


@app.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/version")
def version() -> dict:
    """The running build. CI sets APP_VERSION to the commit SHA, so the UI can show what is deployed."""
    return {"version": APP_VERSION}


@app.get("/api/expenses", response_model=list[ExpenseOut])
def list_expenses(
    category: str | None = None,
    limit: int = Query(100, ge=1, le=500, description="newest expenses to return"),
    db: Session = Depends(get_db),
):
    # Bounded on purpose: an unbounded list grows with the table and drove the HPA to maxReplicas.
    query = select(Expense).order_by(Expense.spent_on.desc(), Expense.id.desc())
    if category:
        query = query.where(Expense.category == category)
    return db.scalars(query.limit(limit)).all()


@app.post("/api/expenses", response_model=ExpenseOut, status_code=201)
def create_expense(payload: ExpenseIn, db: Session = Depends(get_db)):
    expense = Expense(**payload.model_dump())
    db.add(expense)
    db.commit()
    db.refresh(expense)
    EXPENSES_CREATED.labels(expense.category).inc()
    return expense


@app.get("/api/expenses/{expense_id}", response_model=ExpenseOut)
def get_expense(expense_id: int, db: Session = Depends(get_db)):
    return _get_or_404(db, expense_id)


@app.put("/api/expenses/{expense_id}", response_model=ExpenseOut)
def update_expense(expense_id: int, payload: ExpenseIn, db: Session = Depends(get_db)):
    expense = _get_or_404(db, expense_id)
    for field, value in payload.model_dump().items():
        setattr(expense, field, value)
    db.commit()
    db.refresh(expense)
    return expense


@app.delete("/api/expenses/{expense_id}", status_code=204)
def delete_expense(expense_id: int, db: Session = Depends(get_db)) -> Response:
    db.delete(_get_or_404(db, expense_id))
    db.commit()
    return Response(status_code=204)


@app.get("/api/summary", response_model=Summary)
def summary(db: Session = Depends(get_db)):
    rows = db.execute(
        select(Expense.category, func.sum(Expense.amount), func.count(Expense.id))
        .group_by(Expense.category)
        .order_by(func.sum(Expense.amount).desc())
    ).all()
    by_category = [CategoryTotal(category=c, total=Decimal(t), count=n) for c, t, n in rows]
    return Summary(
        total=sum((item.total for item in by_category), Decimal("0")),
        count=sum(item.count for item in by_category),
        by_category=by_category,
    )
