apiVersion: v1
kind: ConfigMap
metadata:
  name: cora-index-script
data:
  job-index.sh: |-
{{ .Files.Get "files/job-index.sh" | indent 4 }}
  waitForSystemToBeRunning.sh: |-
{{ .Files.Get "files/waitForSystemToBeRunning.sh" | indent 4 }}
  login.sh: |-
{{ .Files.Get "files/login.sh" | indent 4 }}
