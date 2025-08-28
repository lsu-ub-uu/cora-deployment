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
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForMq | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-rest
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.rest }}
        ports:
        - containerPort: 8080
        env:
        - name: restToPathSystem
          value: {{ .Values.externalAccess.restToPathSystem }}
        - name: iiifToPathSystem
          value: {{ .Values.externalAccess.iiifToPathSystem }}
        - name: JAVA_OPTS
          value: -Drest.to.path.system=${restToPathSystem} -Diiif.to.path.system=${iiifToPathSystem}        
        volumeMounts:
        - mountPath: "/mnt/data/basicstorage"
          name: converted-files-read-write
      volumes:
        - name: converted-files-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-converted-files-read-write-volume-claim
      imagePullSecrets:
      - name: cora-dockers

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