apiVersion: v1
kind: ConfigMap
metadata:
  name: cora-job-create-missing-sequences-script
data:
  jobListAllSequencesToTriggerCreationIfMissingInDb.sh: |-
{{ .Files.Get "files/jobListAllSequencesToTriggerCreationIfMissingInDb.sh" | indent 4 }}
  waitForSystemToBeRunning.sh: |-
{{ .Files.Get "files/waitForSystemToBeRunning.sh" | indent 4 }}
  dataFromAndToServer.sh: |-
{{ .Files.Get "files/dataFromAndToServer.sh" | indent 4 }}
  login.sh: |-
{{ .Files.Get "files/login.sh" | indent 4 }}
