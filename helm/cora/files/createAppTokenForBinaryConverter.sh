#!/bin/bash
set -euo pipefail

start() {
  waitingForListOfSystemToEnsureSystemIsRunning
  echo "Creating apptoken for binary converter..."
  createApptoken
  createSecretFile
  applySecret
  echo "Apptoken created!"
}

# Retrieve data from Group A API
createApptoken(){
	LOGIN_ID="someLoginId"
	APPTOKEN="someApptoken"
}

createSecretFile() {
  # Base64 encode values for Kubernetes Secret
  LOGIN_ID_B64=$(echo -n "$LOGIN_ID" | base64)
  APPTOKEN_B64=$(echo -n "$APPTOKEN" | base64)

  # Create a secret YAML file
  cat <<EOF > binaryconverter-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: binaryconverter-secret
type: Opaque
data:
  binaryConverterLoginId: $LOGIN_ID_B64
  binaryConverterAppToken: $APPTOKEN_B64
EOF
}

applySecret(){
	kubectl apply -f binaryconverter-secret.yaml
}

start