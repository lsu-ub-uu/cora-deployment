apiVersion: v1
kind: ConfigMap
metadata:
  name: cora-index-script
data:
  job-index.sh: |-
{{ .Files.Get "files/job-index.sh" | indent 4 }}
