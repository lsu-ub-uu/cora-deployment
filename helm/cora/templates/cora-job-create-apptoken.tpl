{{- define "cora.job-create-apptoken" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-create-apptoken
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: {{ .Values.system.name }}-job-create-apptoken
          image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.console }}
          env:
            - name: LOGINID
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.system.name }}-secret
                  key: indexLoginId
            - name: RECORDTYPE_URL
              value: {{ .Values.externalAccess.systemUrl }}/rest/record/recordType
            - name: LOGIN_URL
              value: {{ .Values.externalAccess.systemUrl }}/login/rest/apptoken
            - name: IDP_LOGIN_URL
              value: http://idplogin:8080/idplogin/login/rest/apptoken
          volumeMounts:
            - name: script-volume
              mountPath: /scripts
              readOnly: true
          command: ["/bin/bash"]
          args: ["/scripts/createAppTokenForBinaryConverter.sh"]
      volumes:
        - name: script-volume
          configMap:
            name: cora-create-apptoken-script
{{- end }}