"""create expenses table

Revision ID: 0001
Revises:
Create Date: 2026-10-13
"""
import sqlalchemy as sa
from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "expenses",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(length=120), nullable=False),
        sa.Column("amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("category", sa.String(length=20), nullable=False),
        sa.Column("spent_on", sa.Date(), nullable=False),
        sa.Column("notes", sa.String(length=300), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("ix_expenses_category", "expenses", ["category"])


def downgrade() -> None:
    op.drop_index("ix_expenses_category", table_name="expenses")
    op.drop_table("expenses")
