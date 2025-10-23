{{- define "cora-binaryconverter.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-binaryconverter-{{ .Values.binaryConverter.subName }}-deployment
  labels:
    app: {{ .Values.system.name }}-binaryconverter-{{ .Values.binaryConverter.subName }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-binaryconverter-{{ .Values.binaryConverter.subName }}
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-binaryconverter-{{ .Values.binaryConverter.subName }}
    spec:
      initContainers:
        {{- toYaml .Values.cora.initContainer.waitForMq | nindent 6 }}
      containers:
      - name: {{ .Values.system.name }}-binaryconverter-{{ .Values.binaryConverter.subName }}
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.binaryconverter }}
        env:
        - name: coraBaseUrl
          value: "http://{{ .Values.system.name }}:8080/{{ .Values.system.name }}/rest/"
        - name: apptokenVerifierUrl
          value: "http://login:8080/login/rest/"
        - name: loginId
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: binaryConverterLoginId
        - name: appToken
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: binaryConverterAppToken
        - name: rabbitMqHostName
          value: "{{ .Values.system.name }}-rabbitmq"
        - name: rabbitMqPort
          value: "5672"
        - name: rabbitMqVirtualHost
          value: "/"
        - name: rabbitMqQueueName
          value: {{ .Values.binaryConverter.queueName }}
        - name: fedoraOcflHome
          value: "/tmp/sharedArchiveReadable/{{ .Values.system.pathName }}"
        - name: fileStorageBasePath
          value: "/tmp/sharedFileStorage/{{ .Values.system.pathName }}"
        volumeMounts:
        - mountPath: "/tmp/sharedArchiveReadable/{{ .Values.system.pathName }}"
          name: archive-read-write
          readOnly: true
        - mountPath: "/tmp/sharedFileStorage/{{ .Values.system.pathName }}"
          name: converted-files-read-write
      volumes:
        - name: archive-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-archive-read-write-volume-claim
        - name: converted-files-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-converted-files-read-write-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}
---
{{- end }}

