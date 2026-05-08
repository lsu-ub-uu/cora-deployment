#!/bin/bash
set -uo pipefail

start() {
	local userIds="$@"
	importDependencies
	waitingForListOfSystemToEnsureSystemIsRunning "${RUNNING_URL}"
	
	echo "-> Starting adding appTokens process..."
	loginUsingIdpLogin
	
	echo "-> Remove appTokens and passwords for existing exampleUsers..."
	removeAppTokensAndPasswordFromExampleUsers
	
	echo "-> Remove all existing exampleUsers..."
	deleteAllRecordsForUrl "${RECORD_URL}exampleUser"
	
	echo "-> Create new exampleUsers..."
	addAppTokenAndCreateExampleUsers $userIds
	
	echo "-> Job done..."
	logoutFromCora
}

importDependencies(){
	SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
	source "$SCRIPT_DIR/login.sh"
	source "$SCRIPT_DIR/waitForSystemToBeRunning.sh"
	source "$SCRIPT_DIR/deleteAllRecordsForUrl.sh"
	source "$SCRIPT_DIR/dataFromAndToServer.sh"
	source "$SCRIPT_DIR/appTokenForUser.sh"
}

removeAppTokensAndPasswordFromExampleUsers(){
	local -a readUsers
	getListOfRecordsFromUrl readUsers "user"

	local -A setLoginIds=()
	getSetOfLoginIdsForExampleUsers setLoginIds
	echo "Example users found: ${!setLoginIds[@]}"
		
	for user in "${readUsers[@]}"; do
		local loginId=$(getLoginIdFromUser "$user")
		if [[ -n "${setLoginIds[$loginId]+_}" ]]; then
			echo "Removing apptokens and password for user: $loginId"
			removeAppTokensAndPasswordFromUserRecord "$user"
		fi
	done
}

getSetOfLoginIdsForExampleUsers() {
  local -n _loginIdSet="$1"
  _loginIdSet=()

  local exampleUsers=()
  getListOfRecordsFromUrl exampleUsers "exampleUser"

  local exampleUser loginId
  for exampleUser in "${exampleUsers[@]}"; do
    loginId="$(getLoginIdFromExampleUser "$exampleUser")"
    [[ -z "$loginId" ]] && { echo "skipping: empty loginId" >&2; continue; }
    _loginIdSet["$loginId"]=1
  done
}
	
getLoginIdFromExampleUser(){
	local answer="$1"
	echo $(echo "$answer" | xmllint --xpath 'string(//record/data/exampleUser/loginId)' - 2>/dev/null)
}
	
getLoginIdFromUser(){
	local answer="$1"
	echo $(echo "$answer" | xmllint --xpath 'string(//record/data/user/loginId)' - 2>/dev/null)
}

start "$@"