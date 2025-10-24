{{- define "cora.gatekeeper" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-gatekeeper-deployment
  labels:
    app: {{ .Values.system.name }}-gatekeeper
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-gatekeeper
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-gatekeeper
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForDb | nindent 6 }}
        {{- toYaml .Values.cora.initContainer.waitForMq | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-gatekeeper
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.gatekeeper }}
        ports:
        - containerPort: 8080
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: gatekeeper
spec:
  selector:
    app: {{ .Values.system.name }}-gatekeeper
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end }}