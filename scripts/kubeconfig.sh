#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_DIR="${ROOT_DIR}/.kube"
KUBECONFIG_FILE="${KUBECONFIG_DIR}/config"

mkdir -p "${KUBECONFIG_DIR}"

cd "${ROOT_DIR}/ansible"

ansible control \
  --become \
  -m fetch \
  -a "src=/etc/rancher/k3s/k3s.yaml dest=${KUBECONFIG_FILE} flat=yes"

sed -i.bak 's#https://127.0.0.1:6443#https://192.168.56.10:6443#g' "${KUBECONFIG_FILE}"
rm -f "${KUBECONFIG_FILE}.bak"

echo
echo "Kubeconfig saved to: ${KUBECONFIG_FILE}"
echo
echo "Run:"
echo "export KUBECONFIG=${KUBECONFIG_FILE}"
echo "kubectl get nodes -o wide"