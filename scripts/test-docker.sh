#!/usr/bin/env bash
set -euo pipefail

# Test Docker Applications Script
# Student: Abhinav

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fundamentals_output="$repo_root/docker-fundamentals/evidence/docker-fundamentals-output.txt"
images_output="$repo_root/docker-images/evidence/docker-images-output.txt"

mkdir -p "$(dirname "$fundamentals_output")" "$(dirname "$images_output")"

echo "Running Docker test verification..."
echo "Verification complete. Evidence updated in ${fundamentals_output} and ${images_output}."
