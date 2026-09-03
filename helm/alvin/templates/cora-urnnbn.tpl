---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-urnnbn-deployment
  labels:
    app: {{ .Values.system.name }}-urnnbn
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-urnnbn
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-urnnbn
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForRest | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-urnnbn
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.urnnbn }}
        ports:
        - containerPort: 8080
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
        env:
        - name: databaseUrl
          value: {{ .Values.urnnbn.databaseUrl }}
        - name: databaseUser
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_USER
        - name: databasePassword
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_PASSWORD
        - name: urlPattern
          value: {{ .Values.urnnbn.urlPattern }}
        - name: JAVA_OPTS
          value: -Ddatabase.url="${databaseUrl}" -Ddatabase.user="${databaseUser}" -Ddatabase.password="${databasePassword}" -DurlPatternForUrnNbn="${urlPattern}"
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-urnnbn
spec:
  selector:
    app: {{ .Values.system.name }}-urnnbn
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      
---