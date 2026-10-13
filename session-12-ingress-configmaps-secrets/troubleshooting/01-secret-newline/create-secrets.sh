#!/usr/bin/env bash
# Creates the Secrets for the trailing-newline lab. No password is written to Git.
#   bash create-secrets.sh broken   # reproduces the bug: echo adds "\n" before base64
#   bash create-secrets.sh fixed    # re-encodes the same value with printf %s
set -euo pipefail

mode="${1:?usage: create-secrets.sh broken|fixed}"

# The database admin Secret holds a random value with no trailing newline.
if ! kubectl get secret db-admin >/dev/null 2>&1; then
  kubectl create secret generic db-admin \
    --from-literal=password="$(openssl rand -hex 12)" >/dev/null
  echo "secret/db-admin created"
fi
password="$(kubectl get secret db-admin -o jsonpath='{.data.password}' | base64 --decode)"

case "$mode" in
  broken) encoded="$(echo "$password" | base64)" ;;
  fixed) encoded="$(printf %s "$password" | base64)" ;;
  *) echo "usage: create-secrets.sh broken|fixed" >&2; exit 1 ;;
esac

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ledger-api-db
  labels:
    lab: secret-newline
type: Opaque
data:
  password: ${encoded}
EOF
