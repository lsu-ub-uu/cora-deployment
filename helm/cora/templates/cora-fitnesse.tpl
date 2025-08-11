{{- define "cora.fitnesse" -}}
{{- if .Values.deploy.fitnesse }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-fitnesse-deployment
  labels:
    app: {{ .Values.system.name }}-fitnesse
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-fitnesse
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-fitnesse
    spec:
      containers:
      - name: {{ .Values.system.name }}-fitnesse
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.fitnesse }}
        ports:
        - containerPort: 8090
        env:
        - name: internalApacheAliasAndPort
          value: apache:80
        - name: BASE_URL
          value: http://$(internalApacheAliasAndPort)/{{ .Values.system.name }}/
        - name: LOGIN_URL
          value: http://$(internalApacheAliasAndPort)/{{ .Values.system.name }}/login/
        - name: IDP_LOGIN_URL
          value: http://idplogin:8080/idplogin/
          # Gatekeeper should not be mapped in apache, therefore gatekeeper internal pod alias is used.
        - name: GATEKEEPER_SERVER_URL
          value: http://gatekeeper:8080/gatekeeperserver/
        volumeMounts:
        - mountPath: "/tmp/sharedArchiveReadable/{{ .Values.system.pathName }}"
          name: archive-read-only
          readOnly: true
        - mountPath: "/tmp/sharedFileStorage/{{ .Values.system.pathName }}"
          name: converted-files-read-write
      volumes:
        - name: archive-read-only
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-archive-read-only-volume-claim
        - name: converted-files-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-converted-files-read-only-volume-claim
      imagePullSecrets:
      - name: cora-dockers


---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-fitnesse
spec:
  type: NodePort
  selector:
    app: {{ .Values.system.name }}-fitnesse
  ports:
    - protocol: TCP
      port: 8090
      targetPort: 8090
      nodePort:  {{ .Values.port.fitnesse }}
{{- end }}
{{- end }}