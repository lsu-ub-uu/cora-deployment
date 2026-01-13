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
        env:
        - name: FITNESSE_CONTEXT_ROOT_ARG
          value: {{ .Values.fitnesse.contextRoot }}
        {{- if .Values.apache.useExtraEnvs }}
        {{- toYaml .Values.apache.extraEnvs | nindent 8 }}
        {{- end }}
        volumeMounts:
        - mountPath: "/etc/shibboleth/credentials"
          name: shibd-config
          readOnly: true
      volumes:
        - name: shibd-config
          configMap:
            name: shibd-config
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: apache
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