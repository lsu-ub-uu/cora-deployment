{{- define "cora.iip" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-iip-deployment
  labels:
    app: {{ .Values.system.name }}-iip
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-iip
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-iip
    spec:
      containers:
      - name: {{ .Values.system.name }}-iip
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.iip }}
        ports:
        - containerPort: 80
        env:
        - name: VERBOSITY
          value: "0"
        - name: CORS
          value: "*"
        - name: MAX_IMAGE_CACHE_SIZE
          value: "1000"
        volumeMounts:
        - mountPath: "/mnt/data/basicstorage"
          name: converted-files-read-only
      volumes:
        - name: converted-files-read-only
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-converted-files-read-only-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-iipimageserver
spec:
  selector:
    app: {{ .Values.system.name }}-iip
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
{{- end }}