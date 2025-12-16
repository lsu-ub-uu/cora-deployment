#!/bin/bash
set -uo pipefail

start() {
	local userId=$1
	local note=$2
	importDependencies
	waitingForListOfSystemToEnsureSystemIsRunning "${RUNNING_URL}"
	echo "Starting adding appToken process..."
	loginUsingIdpLogin
	addAppTokenToUserAndStoreAsSecret $userId "$note"
	logoutFromCora
}

importDependencies(){
	SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
	source "$SCRIPT_DIR/login.sh"
	source "$SCRIPT_DIR/waitForSystemToBeRunning.sh"
	source "$SCRIPT_DIR/appTokenForUser.sh"
}

addAppTokenToUserAndStoreAsSecret() {
	importDependencies
	local userId="$1"
	local note="$2"
    local updateAnswer=$(addAndStoreAppTokenToUser "${RECORD_URL}user/$userId" "$note")
    local token=$(extractTokenFromUpdateAnswer "$updateAnswer")
    local loginId=$(extractLoginIdFromUpdateAnswer "$updateAnswer")
#	createSecretFile "${loginId}" "${token}"
#	applySecret
}

extractLoginIdFromUpdateAnswer(){
	local updateAnswer="$1"
	local loginId=$(echo "$updateAnswer" | \
		xmllint --xpath 'string(/record/data/user/loginId)' - )
	echo "$loginId"
}

createSecretFile() {
	local loginId=$1
	local token=$2
	# Base64 encode values for Kubernetes Secret
	local loginIdB64=$(echo -n "$loginId" | base64)
	local appTokenB64=$(echo -n "$token" | base64)

	# Create a secret YAML file
cat <<EOF > binaryconverter-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: binaryconverter-secret
type: Opaque
data:
  binaryConverterLoginId: $loginIdB64
  binaryConverterAppToken: $appTokenB64
EOF
}

applySecret(){
	kubectl apply -f binaryconverter-secret.yaml
}

start "$@"