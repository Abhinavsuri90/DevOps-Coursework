from logging.config import fileConfig

from sqlalchemy import create_engine, text

from alembic import context
from app import models  # noqa: F401  (registers the tables on Base.metadata)
from app.config import DATABASE_URL
from app.db import Base

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata
MIGRATION_LOCK_ID = 7211  # any constant shared by every replica


def run_migrations_online() -> None:
    engine = create_engine(DATABASE_URL)
    with engine.connect() as connection:
        if connection.dialect.name == "postgresql":
            # Several backend replicas start at once; only one may migrate at a time.
            connection.execute(text("SELECT pg_advisory_lock(:id)"), {"id": MIGRATION_LOCK_ID})
            connection.commit()
        try:
            context.configure(connection=connection, target_metadata=target_metadata)
            with context.begin_transaction():
                context.run_migrations()
        finally:
            if connection.dialect.name == "postgresql":
                connection.execute(text("SELECT pg_advisory_unlock(:id)"), {"id": MIGRATION_LOCK_ID})
                connection.commit()


run_migrations_online()
