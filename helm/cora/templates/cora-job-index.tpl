{{- define "cora.job-index" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-index
  annotations:
    "helm.sh/hook": post-install
#    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
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
              value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/record/recordType"
            - name: INDEX_URL
              value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/record/index"
            - name: LOGIN_URL
              value: "http://login:8080/login/rest/apptoken"
            - name: CHECK_URL
              value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/record/system"
          volumeMounts:
            - name: script-volume
              mountPath: /scripts
              readOnly: true
          command: ["/bin/bash"]
          args: ["/scripts/job-index.sh"]
          #command: ["/bin/sh", "-c"]
          #args: ["echo hello && sleep 36000000"]
      volumes:
        - name: script-volume
          configMap:
            name: cora-index-script
{{- end }}