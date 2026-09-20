#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
kubectl delete -f "$script_dir/ingress.yaml" --ignore-not-found
kubectl delete -f "$script_dir/frontend.yaml" --ignore-not-found
kubectl delete -f "$script_dir/backend.yaml" --ignore-not-found
kubectl delete -f "$script_dir/secret.yaml" --ignore-not-found
kubectl delete -f "$script_dir/configmap.yaml" --ignore-not-found
