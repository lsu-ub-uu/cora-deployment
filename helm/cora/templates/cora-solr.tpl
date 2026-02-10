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
      securityContext:
        fsGroup: 8983
      containers:
      - name: {{ .Values.system.name }}-solr
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.solr }}
        ports:
        - containerPort: 8983
        args: ["solr-precreate", "coracore", "/opt/solr/server/solr/configsets/coradefaultcore"]
        volumeMounts:
        - mountPath: "/var/solr/data"
          name: index-read-write
      volumes:
        - name: index-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-index-read-write-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

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