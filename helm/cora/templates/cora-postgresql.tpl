{{- define "cora.postgresql" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.system.name }}-postgresql-deployment
  labels:
    app: {{ .Values.system.name }}-postgresql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-postgresql
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-postgresql
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: {{ .Values.system.name }}-postgresql
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.postgresql }}
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: {{ .Values.system.name }}
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
        - name: DATA_DIVIDERS
          valueFrom:
            configMapKeyRef:
              name: {{ .Values.system.name }}-config
              key: dataDividers
        volumeMounts:
        - mountPath: "/var/lib/postgresql"
          name: postgresql-volume
      volumes:
        - name: postgresql-volume
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-postgres-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-postgresql
spec:
  selector:
    app: {{ .Values.system.name }}-postgresql
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
{{- end }}
