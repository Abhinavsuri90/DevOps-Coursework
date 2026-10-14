"""Settings read from environment variables (12-factor style)."""

import os

DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./spendwise.db")
APP_VERSION = os.environ.get("APP_VERSION", "dev")
CATEGORIES = ("food", "travel", "books", "rent", "fun", "other")
