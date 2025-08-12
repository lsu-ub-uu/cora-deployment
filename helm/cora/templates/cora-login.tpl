{{- define "cora.login" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-login-deployment
  labels:
    app: {{ .Values.system.name }}-login
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-login
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-login
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForDb | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-login
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.login }}
        ports:
        - containerPort: 8080
        env:
        - name: loginPublicPathToSystem
          value: /login/rest/
        - name: POSTGRES_URL
          value: jdbc:postgresql://{{ .Values.system.name }}-postgresql:5432/{{ .Values.system.name }}
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_PASSWORD
        - name: JAVA_OPTS
          value: -Dlogin.public.path.to.system=$(loginPublicPathToSystem) -Ddburl=$(POSTGRES_URL) -Ddbusername=$(POSTGRES_USER) -Ddbpassword=$(POSTGRES_PASSWORD)
        
      imagePullSecrets:
      - name: cora-dockers

---

apiVersion: v1
kind: Service
metadata:
  name: login
spec:
  type: NodePort
  selector:
    app: {{ .Values.system.name }}-login
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort:  {{ .Values.port.login }}
{{- end }}