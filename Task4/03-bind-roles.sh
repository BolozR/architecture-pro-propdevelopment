#!/usr/bin/env bash
set -euo pipefail

for domain in sales utilities finance data; do
  kubectl -n "$domain" create rolebinding prop-viewers \
    --clusterrole=prop-viewer --group="prop-$domain-viewers" \
    --dry-run=client -o yaml | kubectl apply -f -

  kubectl -n "$domain" create rolebinding prop-operators \
    --clusterrole=prop-operator --group="prop-$domain-operators" \
    --dry-run=client -o yaml | kubectl apply -f -
done

kubectl create clusterrolebinding prop-security-admins \
  --clusterrole=prop-security-admin --group=prop-security-admins \
  --dry-run=client -o yaml | kubectl apply -f -

# Убираем прежние общекластерные привязки из этого задания, если они остались.
kubectl delete clusterrolebinding prop-viewers prop-operators --ignore-not-found
