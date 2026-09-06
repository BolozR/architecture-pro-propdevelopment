#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "${ROOT_DIR}/01-create-namespace.yaml"

for file in "${ROOT_DIR}"/insecure-manifests/*.yaml; do
  if kubectl apply --dry-run=server -f "$file" >/dev/null 2>&1; then
    echo "ОШИБКА: небезопасный манифест принят: $file"
    exit 1
  fi
  echo "Отклонён как ожидалось: $file"
done

for file in "${ROOT_DIR}"/secure-manifests/*.yaml; do
  kubectl apply --dry-run=server -f "$file" >/dev/null
  echo "Принят безопасный манифест: $file"
done

