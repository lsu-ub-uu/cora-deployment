{{- define "cora.idplogin" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-idplogin-deployment
  labels:
    app: {{ .Values.system.name }}-idplogin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-idplogin
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-idplogin
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForDb | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-idplogin
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.idplogin }}
        ports:
        - containerPort: 8080
        env:
        - name: mainSystemDomain
          value: {{ .Values.externalAccess.systemUrl }}
        - name: tokenLogoutUrl
          value: {{ .Values.externalAccess.systemUrl }}/login/rest/authToken/
        - name: JAVA_OPTS
          value: -Dmain.system.domain=${mainSystemDomain} -Dtoken.logout.url=${tokenLogoutUrl}        
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: idplogin
spec:
  selector:
    app: {{ .Values.system.name }}-idplogin
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
{{- end -}}
