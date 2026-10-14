# SpendWise API image. Build context: final-devops-project/
#   docker build -f docker/backend.Dockerfile -t spendwise-backend .
FROM python:3.13-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /srv
COPY application/backend/requirements.txt .
# Install dependencies, then remove pip (not needed at runtime; it bundles its own
# copies of urllib3/msgpack/setuptools that image scanners flag), and add a non-root user.
RUN pip install --no-cache-dir -r requirements.txt \
 && pip uninstall -y pip \
 && adduser -D -u 10001 spendwise

COPY application/backend/alembic.ini application/backend/entrypoint.sh ./
COPY application/backend/alembic ./alembic
COPY application/backend/app ./app

USER 10001
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')"
ENTRYPOINT ["./entrypoint.sh"]
