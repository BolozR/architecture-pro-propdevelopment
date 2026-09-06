#!/usr/bin/env bash
set -euo pipefail

label="$(kubectl get namespace audit-zone -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')"
test "$label" = "restricted"

kubectl get constrainttemplates \
  k8sdenyprivileged k8sdenyhostpath k8srequiresafepod >/dev/null
kubectl get k8sdenyprivileged deny-privileged-audit-zone >/dev/null
kubectl get k8sdenyhostpath deny-hostpath-audit-zone >/dev/null
kubectl get k8srequiresafepod require-safe-pod-audit-zone >/dev/null

echo "PodSecurity и ограничения Gatekeeper настроены."

