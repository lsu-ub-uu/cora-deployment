#!/bin/bash

NAMESPACE="$1"

if [ -z "$NAMESPACE" ]; then
  echo "Usage: watchKube <namespace>"
  exit 1
fi

watch -n 1 "
  kubectl get pod,service,pv,pvc,jobs -n $NAMESPACE;
  echo;
  echo 'Images in use:';
  kubectl get pods -n "$NAMESPACE" -o jsonpath="{.items[*].spec.containers[*].image}" | tr ' ' '\n' | sort | uniq
  echo;
  helm -n $NAMESPACE ls;
"

