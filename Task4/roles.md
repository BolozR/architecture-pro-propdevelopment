# Роли Kubernetes

для каждого домена свой namespace: sales, utilities, finance и data.

| роль | группа | кто | права |
|---|---|---|---|
| prop-viewer | `prop-<домен>-viewers` | аналитики и поддержка | просмотр ресурсов своего namespace, без Secret |
| prop-operator | `prop-<домен>-operators` | DevOps | настройка приложений своего namespace, без прямого доступа к Secret и RBAC |
| prop-security-admin | prop-security-admins | специалист ИБ | секреты, RBAC и сетевые политики всех доменов |

для проверки создаются analyst из data, devops из utilities и security. Первые две роли выдаются через RoleBinding, роль ИБ — через ClusterRoleBinding.

## Запуск

```bash
minikube start
cd Task4
bash 01-create-users.sh
bash 02-create-roles.sh
bash 03-bind-roles.sh
```

скрипты создают пользователей, роли и привязки. Последний скрипт также убирает старые общекластерные привязки prop-viewers и prop-operators, если они остались.

## Проверка

```bash
kubectl --context=analyst@minikube auth can-i get pods -n data
kubectl --context=analyst@minikube auth can-i get pods -n finance
kubectl --context=devops@minikube auth can-i create deployments -n utilities
kubectl --context=devops@minikube auth can-i get secrets -n utilities
kubectl --context=security@minikube auth can-i get secrets -n finance
```

ожидаемые ответы: yes, no, yes, no, yes.
