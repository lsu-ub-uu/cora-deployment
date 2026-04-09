{{- define "cora.job-updatedb" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-updatedb
  labels:
    app: {{ .Values.system.name }}-job-updatedb
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-updatedb
    spec:
      restartPolicy: Never
      containers:
      - name: {{ .Values.system.name }}-job-updatedb
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.postgresql }}
        workingDir: /
        command: ["/bin/bash", "-lc"]
        args:
          - ./updatedb/updateDb.sh
        env:
        - name: applicationVersion
          value: {{ .Chart.AppVersion }}
        - name: POSTGRES_HOST
          value: {{ .Values.system.name }}-postgresql
        - name: POSTGRES_DB
          value: {{ .Values.system.name }}
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_PASSWORD
        - name: DATA_DIVIDERS
          value: {{ .Values.data.dataDividers }}
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}
{{- end }}