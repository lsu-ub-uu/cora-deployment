#!/bin/bash
set -uo pipefail

start() {
	listAllSequencesToTriggerCreationIfMissingInDb
}

listAllSequencesToTriggerCreationIfMissingInDb() {
  importDependencies
  waitingForListOfSystemToEnsureSystemIsRunning "${RUNNING_URL}"
  loginUsingIdpLogin
  listAllSequences
  logoutFromCora
}

importDependencies(){
	SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
	source "$SCRIPT_DIR/dataFromAndToServer.sh"
	source "$SCRIPT_DIR/waitForSystemToBeRunning.sh"
	source "$SCRIPT_DIR/login.sh"
}

listAllSequences(){
  echo "Listing all sequences to trigger creation if missing in db ..."
  local xml=$(readRecordListFromUrl "${AUTH_TOKEN}" "${RECORD_URL}sequence/")
  echo "... Listing all sequences to trigger creation if missing in db"
}

start "$@"