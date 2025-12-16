apiVersion: v1
kind: ConfigMap
metadata:
  name: cora-create-example-users-script
data:
  jobAddAppTokenAndCreateExampleUsers.sh: |-
{{ .Files.Get "files/jobAddAppTokenAndCreateExampleUsers.sh" | indent 4 }}
  waitForSystemToBeRunning.sh: |-
{{ .Files.Get "files/waitForSystemToBeRunning.sh" | indent 4 }}
  dataFromAndToServer.sh: |-
{{ .Files.Get "files/dataFromAndToServer.sh" | indent 4 }}
  appTokenForUser.sh: |-
{{ .Files.Get "files/appTokenForUser.sh" | indent 4 }}
  login.sh: |-
{{ .Files.Get "files/login.sh" | indent 4 }}
