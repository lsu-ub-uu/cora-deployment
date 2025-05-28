{{- define "cora.fedora" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.system.name }}-fedora-deployment
  labels:
    app: {{ .Values.system.name }}-fedora
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-fedora
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-fedora
    spec:
      containers:
      - name: {{ .Values.system.name }}-fedora
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.fedora }}
        ports:
        - containerPort: 8080
        volumeMounts:
        - mountPath: "/usr/local/tomcat/fcrepo-home/data/ocfl-root"
          name: archive-read-write
      volumes:
        - name: archive-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-archive-read-write-volume-claim
      imagePullSecrets:
      - name: cora-dockers

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-fedora
spec:
  selector:
    app: {{ .Values.system.name }}-fedora
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end }}