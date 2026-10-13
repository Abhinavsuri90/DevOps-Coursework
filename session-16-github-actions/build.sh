#!/usr/bin/env bash
# Packages the application source into dist/ with build metadata.
# CI uploads dist/ as a workflow artifact.
set -euo pipefail
cd "$(dirname "$0")"

version="${APP_VERSION:-$(git rev-parse --short HEAD 2>/dev/null || echo dev)}"
rm -rf dist && mkdir -p dist

tar -czf "dist/gpa-calculator-${version}.tar.gz" app requirements.txt Dockerfile
{
  echo "app=gpa-calculator"
  echo "version=${version}"
  echo "built_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "python=$(python3 --version 2>&1)"
  echo "commit=${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
  echo "run=${GITHUB_RUN_ID:-local}"
} > dist/build-info.txt

ls -l dist
cat dist/build-info.txt
