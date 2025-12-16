{{- define "cora.job-create-example-users" -}}
{{- if gt (len (default (list) .Values.data.exampleUsers)) 0 }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-create-example-users
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: {{ .Values.system.name }}-job-example-users
          image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.console }}
          env:
            - name: LOGINID
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.system.name }}-secret
                  key: indexLoginId
            - name: RUNNING_URL
              value: {{ .Values.externalAccess.systemUrl }}/rest/record/system
            - name: RECORD_URL
              value: {{ .Values.externalAccess.systemUrl }}/rest/record/
            - name: IDP_LOGIN_URL
              value: http://idplogin:8080/idplogin/login/rest/apptoken
          volumeMounts:
            - name: script-volume
              mountPath: /scripts
              readOnly: true
          command: ["/bin/bash"]
          args: 
            - "/scripts/jobAddAppTokenAndCreateExampleUsers.sh"
          {{- range .Values.data.exampleUsers }}
            - "{{ . }}"
          {{- end }}
      volumes:
        - name: script-volume
          configMap:
            name: cora-create-example-users-script
{{- end }}
{{- end }}