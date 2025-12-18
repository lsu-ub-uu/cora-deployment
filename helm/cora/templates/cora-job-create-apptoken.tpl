{{- define "cora.job-create-apptoken" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.system.name }}-job-create-apptoken
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
#    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      serviceAccountName: binaryconverter-job-sa
      restartPolicy: OnFailure
      containers:
        - name: {{ .Values.system.name }}-job-create-apptoken-binaryconverter
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
            - "/scripts/jobAddAppTokenToUserAndStoreAsSecret.sh"
            - "binaryConverter"
            - "AppToken used by internal binary converter processes, do not remove!"
        {{- if .Values.deploy.fitnesse }}
        - name: {{ .Values.system.name }}-job-create-apptoken-fitnesseadmin
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
            - "/scripts/jobAddAppTokenToUserAndStoreAsSecret.sh"
            - "131313"
            - "AppToken used by internal binary converter processes, do not remove!"
        - name: {{ .Values.system.name }}-job-create-apptoken-fitnesseuser
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
            - "/scripts/jobAddAppTokenToUserAndStoreAsSecret.sh"
            - "121212"
            - "AppToken used by internal binary converter processes, do not remove!"
        {{- end }}
      volumes:
        - name: script-volume
          configMap:
            name: cora-create-apptoken-script
{{- end }}