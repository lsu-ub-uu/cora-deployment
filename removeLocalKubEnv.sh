#!/usr/bin/env bash
set -e

# Usage function
usage() {
    cat <<EOF
Usage: $(basename "$0") <system_name>

<system_name>    The system to clean up (systemone | diva | alvin)

Examples:
  $(basename "$0") systemone
  $(basename "$0") diva
EOF
    exit 1
}

# Validate args
if [[ "$1" == "--help" || "$#" -ne 1 ]]; then
    usage
fi

SYSTEM="$1"

if [[ "$SYSTEM" != "systemone" && "$SYSTEM" != "diva" && "$SYSTEM" != "alvin" ]]; then
    echo "Error: Invalid system '$SYSTEM'. Must be one of: systemone, diva, alvin"
    usage
fi

kubectl delete namespace "$SYSTEM" --ignore-not-found
kubectl get pv -o name | grep "^persistentvolume/${SYSTEM}" | xargs -r kubectl delete
minikube ssh -- "sudo rm -rf /mnt/minikube/${SYSTEM}"