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
          # Specific for alvin, it might be moved
        - name: ALVIN_CLIENT_CONTEXT_ROOT_ARG
          value: {{ .Values.externalAccess.alvinClientPath }}
        volumeMounts:
        - mountPath: "/etc/shibboleth/credentials"
          name: credentials-read-only
          readOnly: true
      volumes:
        - name: credentials-read-only
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-{{ .Values.shibboleth.domain }}-credentials-read-only-volume-claim
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