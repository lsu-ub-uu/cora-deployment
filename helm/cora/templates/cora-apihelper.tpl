{{- define "cora.apihelper" -}}
{{- if .Values.deploy.apihelper }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-apihelper-deployment
  labels:
    app: {{ .Values.system.name }}-apihelper
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-apihelper
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-apihelper
    spec:
      containers:
      - name: {{ .Values.system.name }}-apihelper
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.apihelper }}
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-apihelper
spec:
  selector:
    app: {{ .Values.system.name }}-apihelper
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

{{- end }}
{{- end }}
