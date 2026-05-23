#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ "${ENVIRONMENT}" != "staging" && "${ENVIRONMENT}" != "production" ]]; then
  echo "Usage: ./scripts/local_bootstrap.sh <staging|production>"
  exit 1
fi

cd infra/bootstrap
terraform init
terraform apply -var-file="${ENVIRONMENT}.tfvars"
