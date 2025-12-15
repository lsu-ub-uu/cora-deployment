{{- define "cora.rest" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-rest-deployment
  labels:
    app: {{ .Values.system.name }}-rest
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-rest
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-rest
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForDb | nindent 6 }}
        {{- toYaml .Values.cora.initContainer.waitForMq | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-rest
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.rest }}
        ports:
        - containerPort: 8080
        env:
        - name: applicationName
          value: {{ .Values.externalAccess.applicationName }}
        - name: deploymentName
          value: {{ .Values.externalAccess.deploymentName }}
        - name: coraVersion
          value: {{ .Values.externalAccess.coraVersion }}
        - name: applicationVersion
          value: {{ .Values.externalAccess.applicationVersion }}
        - name: loginRestUrl
          value: {{ .Values.externalAccess.loginRestUrl }}
        - name: JAVA_OPTS
          value: -DdeploymentInfo.applicationName=${applicationName} -DdeploymentInfo.deploymentName=${deploymentName} -DdeploymentInfo.coraVersion=${coraVersion} -DdeploymentInfo.applicationVersion=${applicationVersion} -DdeploymentInfo.loginRestUrl=${loginRestUrl} 
        volumeMounts:
        - mountPath: "/mnt/data/basicstorage"
          name: converted-files-read-write
      volumes:
        - name: converted-files-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-converted-files-read-write-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}
spec:
  selector:
    app: {{ .Values.system.name }}-rest
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end }}