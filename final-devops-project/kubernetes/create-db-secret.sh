#!/usr/bin/env bash
# Creates the database Secret once per cluster with a random password.
# The password lives only in the cluster, never in Git.
set -euo pipefail
NAMESPACE="${1:-spendwise}"
if kubectl -n "$NAMESPACE" get secret spendwise-db >/dev/null 2>&1; then
  echo "secret/spendwise-db already exists in $NAMESPACE"
else
  kubectl -n "$NAMESPACE" create secret generic spendwise-db \
    --from-literal=password="$(openssl rand -hex 16)" >/dev/null
  echo "secret/spendwise-db created in $NAMESPACE"
fi
