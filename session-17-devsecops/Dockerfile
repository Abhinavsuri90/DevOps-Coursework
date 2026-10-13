# Small Alpine-based runtime with a non-root user.
FROM python:3.13-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /srv
COPY requirements.txt .
# pip is only needed to install dependencies. Removing it drops the libraries it
# bundles (urllib3, msgpack, setuptools) that Trivy flagged in the first scan.
RUN pip install --no-cache-dir -r requirements.txt \
 && pip uninstall -y pip \
 && adduser -D -u 10001 appuser

COPY app ./app
USER 10001

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
