#!/usr/bin/env bash
set -euo pipefail

for domain in sales utilities finance data; do
  kubectl create namespace "$domain" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prop-viewer
rules:
  - apiGroups: ["", "apps", "batch", "networking.k8s.io"]
    resources: ["pods", "pods/log", "services", "endpoints", "configmaps", "events", "deployments", "replicasets", "statefulsets", "daemonsets", "jobs", "cronjobs", "ingresses", "networkpolicies"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prop-operator
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log", "services", "endpoints", "configmaps", "events", "persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["apps", "batch", "networking.k8s.io"]
    resources: ["deployments", "replicasets", "statefulsets", "daemonsets", "jobs", "cronjobs", "ingresses", "networkpolicies"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prop-security-admin
rules:
  - apiGroups: [""]
    resources: ["secrets", "serviceaccounts", "pods", "pods/log", "events"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
YAML
