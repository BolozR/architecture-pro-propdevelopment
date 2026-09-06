#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-minikube}"
CA_DIR="${2:-${HOME}/.minikube}"
OUTPUT_DIR="${3:-./users}"

mkdir -p "${OUTPUT_DIR}"

create_user() {
  local user_name="$1"
  local group_name="$2"

  openssl genrsa -out "${OUTPUT_DIR}/${user_name}.key" 2048
  openssl req -new \
    -key "${OUTPUT_DIR}/${user_name}.key" \
    -out "${OUTPUT_DIR}/${user_name}.csr" \
    -subj "/CN=${user_name}/O=${group_name}"
  openssl x509 -req \
    -in "${OUTPUT_DIR}/${user_name}.csr" \
    -CA "${CA_DIR}/ca.crt" \
    -CAkey "${CA_DIR}/ca.key" \
    -CAcreateserial \
    -out "${OUTPUT_DIR}/${user_name}.crt" \
    -days 365

  kubectl config set-credentials "${user_name}" \
    --client-certificate="${OUTPUT_DIR}/${user_name}.crt" \
    --client-key="${OUTPUT_DIR}/${user_name}.key" \
    --embed-certs=true
  kubectl config set-context "${user_name}@${PROFILE}" \
    --cluster="${PROFILE}" \
    --user="${user_name}"
}

create_user analyst prop-data-viewers
create_user devops prop-utilities-operators
create_user security prop-security-admins

echo "Созданы пользователи analyst, devops и security."
