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
        - name: indexer
          image: bitnami/kubectl:latest
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
            - name: INDEX_URL
              value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/record/index"
            - name: LOGIN_URL
              value: "http://login:8080/login/rest/apptoken"
            - name: CHECK_URL
              value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/record/system"
          command: ["/bin/sh", "-c"]
          args:
            - |
              echo "Waiting for app readiness..."
              until curl -s --fail ${CHECK_URL}; do sleep 5; done

              echo "App is ready. Running indexing script..."

              bash <<'EOF'
              #!/bin/bash
              echo '11111111111111111111'
              start(){
              echo '33333333333'
                login
                for type in recordType validationType metadata text collectTerm presentation guiElement system permissionUnit; do
                  indexMetadata $type
                done
                logoutFromCora
              }

              login(){
                local loginAnswer=$(curl -s -X POST -H "Content-Type: application/vnd.cora.login" -k -i ${LOGIN_URL} --data "${LOGINID}"$'\n'"${APP_TOKEN}")
                echo 'LoginAnswer: '${loginAnswer}
                AUTH_TOKEN=$(echo ${loginAnswer} | grep -o -P '(?<={"name":"token","value":").*?(?="})')
                AUTH_TOKEN_DELETE_URL=$(echo ${loginAnswer} | grep -o -P '(?<="url":").*?(?=")')
                echo 'Logged in, got authToken: '${AUTH_TOKEN}
              }

              indexMetadata(){
                echo ""
                local recordType=$1
                echo 'Indexing recordType: '${recordType}
                local indexAnswer=$(curl -s -X POST -k -H "authToken: ${AUTH_TOKEN}" -H "Accept: application/vnd.cora.record+json" -i ${INDEX_URL}/${recordType})
                echo 'IndexAnswer: '${indexAnswer}
                local indexAnswerId=$(echo ${indexAnswer} | grep -o -P '(?<="name":"id","value":").*?(?=")')
                echo 'IndexAnswerId: '${indexAnswerId}
              }

              logoutFromCora(){
                echo
                echo 'Logging out on' ${AUTH_TOKEN_DELETE_URL}
                curl -s -X DELETE -k -H "authToken: ${AUTH_TOKEN}" -i ${AUTH_TOKEN_DELETE_URL}
                echo 'Logged out'
              }

              start
              echo '22222222222222'
              EOF
{{- end }}
