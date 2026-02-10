#!/usr/bin/env bash
set -e

# Usage function
usage() {
	cat <<EOF
Usage: $(basename "$0") <system_name>
<system_name> The system to deploy (systemone | diva | alvin)
Examples:
  $(basename "$0") systemone
EOF
    exit 1
}

# Validate args
if [[ "$1" == "--help" || "$#" -lt 1 ]]; then
    usage
fi

SYSTEM="$1"
shift

if [[ "$SYSTEM" != "systemone" && "$SYSTEM" != "diva" && "$SYSTEM" != "alvin" ]]; then
    echo "Error: Invalid system '$SYSTEM'. Must be one of: systemone, diva, alvin"
    usage
fi

# Helm values file naming assumption
VALUES_FILE="${SYSTEM}-local-values.yaml"
SECRET_FILE="${SYSTEM}-secret.yaml"
PERMISSION_VOLUMES_FILE="${SYSTEM}-minikube-persistent-volumes.yaml"
CONFIG_MAP_FILE="${SYSTEM}-config-map.yaml"
DATE=$(date +%Y%m%d)
RELEASE="my${DATE}${SYSTEM}"

# Helm repo setup
helm repo add epc https://helm.epc.ub.uu.se/
helm repo update

# Move to helm directory
cd helm

# Update dependencies
helm dependency build cora/
helm dependency update "${SYSTEM}/"

# Create namespace if not exists
kubectl create namespace "${SYSTEM}" --dry-run=client -o yaml | kubectl apply -f -

# Apply Kubernetes manifests
kubectl apply -f "${SECRET_FILE}" --namespace="${SYSTEM}"
kubectl apply -f "${PERMISSION_VOLUMES_FILE}" --namespace="${SYSTEM}"
kubectl apply -f "${CONFIG_MAP_FILE}" --namespace="${SYSTEM}"

# Install Helm chart
helm install "${RELEASE}" "${SYSTEM}" --namespace "${SYSTEM}" -f "${VALUES_FILE}"
