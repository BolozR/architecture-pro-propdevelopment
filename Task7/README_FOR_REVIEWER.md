# Безопасность pod

в audit-zone включён restricted. В insecure-manifests — примеры с privileged, hostPath и root. В secure-manifests — исправленные pod.

Gatekeeper запрещает privileged и hostPath, требует runAsNonRoot и readOnlyRootFilesystem.

## Запуск

Gatekeeper должен быть установлен. Из папки Task7:

```bash
kubectl apply -f 01-create-namespace.yaml
kubectl apply -f gatekeeper/constraint-templates

kubectl wait --for=condition=Established --timeout=60s \
  crd/k8sdenyprivileged.constraints.gatekeeper.sh \
  crd/k8sdenyhostpath.constraints.gatekeeper.sh \
  crd/k8srequiresafepod.constraints.gatekeeper.sh

kubectl apply -f gatekeeper/constraints
```

## Проверка

```bash
bash verify/verify-admission.sh
bash verify/validate-security.sh
```

небезопасные pod должны отклоняться, безопасные — проходить server-side dry run.

audit-policy.yaml подключается в настройках API server.
