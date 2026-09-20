#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
command -v openssl >/dev/null || { echo 'openssl is required' >&2; exit 1; }
kubectl cluster-info >/dev/null
if command -v minikube >/dev/null && [[ "$(kubectl config current-context)" == "minikube" ]]; then
  minikube addons enable ingress
  kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=180s
fi
kubectl apply -f "$script_dir/configmap.yaml"
kubectl apply -f "$script_dir/secret.yaml"
kubectl create secret generic yatri-demo-secret \
  --from-file=db-password=<(openssl rand -hex 16 | tr -d '\n') \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl label secret yatri-demo-secret app=yatri-app --overwrite
kubectl apply -f "$script_dir/backend.yaml"
kubectl apply -f "$script_dir/frontend.yaml"
kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl rollout status deployment/yatri-frontend --timeout=180s
kubectl apply -f "$script_dir/ingress.yaml"
kubectl get configmap,secret,ingress,deployment,service,pods -l app=yatri-app
