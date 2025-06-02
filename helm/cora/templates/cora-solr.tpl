{{- define "cora.solr" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-solr-deployment
  labels:
    app: {{ .Values.system.name }}-solr
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-solr
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-solr
    spec:
      containers:
      - name: {{ .Values.system.name }}-solr
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.solr }}
        ports:
        - containerPort: 8983
        args: ["solr-precreate", "coracore", "/opt/solr/server/solr/configsets/coradefaultcore"]
      imagePullSecrets:
      - name: cora-dockers

---

apiVersion: v1
kind: Service
metadata:
  name: solr
spec:
  selector:
    app: {{ .Values.system.name }}-solr
  ports:
    - protocol: TCP
      port: 8983
      targetPort: 8983
{{- end }}