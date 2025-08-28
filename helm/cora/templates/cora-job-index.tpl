{{- define "cora.job-index" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-index
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: {{ .Values.system.name }}-job-index
          image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.jobindex }}
          env:
            - name: LOGINID
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.system.name }}-secret
                  key: indexLoginId
            - name: APP_TOKEN
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.system.name }}-secret
                  key: indexAppToken
            - name: RECORDTYPE_URL
              value: {{ .Values.externalAccess.systemUrl }}/rest/record/recordType
            - name: LOGIN_URL
              value: {{ .Values.externalAccess.systemUrl }}/login/rest/apptoken
          volumeMounts:
            - name: script-volume
              mountPath: /scripts
              readOnly: true
          command: ["/bin/bash"]
          args: ["/scripts/job-index.sh"]
      volumes:
        - name: script-volume
          configMap:
            name: cora-index-script
{{- end }}