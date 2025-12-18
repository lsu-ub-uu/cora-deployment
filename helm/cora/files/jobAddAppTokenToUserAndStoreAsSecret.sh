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
	createSecretFile "${userId,,}" "${loginId}" "${token}"
#	applySecret
}

extractLoginIdFromUpdateAnswer(){
	local updateAnswer="$1"
	local loginId=$(echo "$updateAnswer" | \
		xmllint --xpath 'string(/record/data/user/loginId)' - )
	echo "$loginId"
}

createSecretFile() {
	local userId=$1
	local loginId=$2
	local token=$3
	# Base64 encode values for Kubernetes Secret
	local loginIdB64=$(echo -n "$loginId" | base64)
	local appTokenB64=$(echo -n "$token" | base64)
	
	kubectl create secret generic ${userId}-secret \
  		--from-literal=loginId="$loginId" \
  		--from-literal=appToken="$token" \
  		--dry-run=client -o yaml | kubectl apply -f -
}

start "$@"