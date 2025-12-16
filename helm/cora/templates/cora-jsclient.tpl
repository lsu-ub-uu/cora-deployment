{{- define "cora.jsclient" -}}
{{- if .Values.deploy.jsclient }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-jsclient-deployment
  labels:
    app: {{ .Values.system.name }}-jsclient
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-jsclient
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-jsclient
    spec:
      containers:
      - name: {{ .Values.system.name }}-jsclient
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.jsclient }}
        ports:
        - containerPort: 8080
        env:
        - name: SERVER_REST_URL
          value: {{ .Values.externalAccess.systemRestUrl }}
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-jsclient
spec:
  selector:
    app: {{ .Values.system.name }}-jsclient
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end }}
{{- end }}