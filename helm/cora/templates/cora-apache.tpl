{{- define "cora.apache" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-apache-deployment
  labels:
    app: {{ .Values.system.name }}-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-apache
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-apache
    spec:
      containers:
      - name: {{ .Values.system.name }}-apache
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.apache }}
        ports:
        - containerPort: 80
      imagePullSecrets:
      - name: cora-dockers

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-apache-proxy
spec:
  type: NodePort
  selector:
    app: {{ .Values.system.name }}-apache
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort:  {{ .Values.port.apache }}
{{- end }}