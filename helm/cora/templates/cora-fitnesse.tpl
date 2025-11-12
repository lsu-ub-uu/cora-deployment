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
        - name: CONTEXT_ROOT_ARG
          value: {{ .Values.fitnesse.contextRoot }}
        - name: BASE_URL
          value: {{ .Values.fitnesse.baseUrl }}
#          value: http://apache/
        - name: LOGIN_URL
          value: {{ .Values.fitnesse.loginUrl }}
#          value: http://apache/login/
          # The internal apache vhost config has a routing for idplogin which requires credentials 
          # and since we do not have access to shibboleth in fitnesse, the solution is to by pass 
          # the routing in the apache and call idplogin internally.
        - name: IDP_LOGIN_URL
          value: http://idplogin:8080/idplogin/
          # Gatekeeper should not be mapped in apache, therefore gatekeeper internal pod alias is used.
        - name: GATEKEEPER_SERVER_URL
          value: http://gatekeeper:8080/gatekeeperserver/
        - name: FITNESSE_ADMIN_LOGIN_ID
          value: fitnesseAdmin@system.cora.uu.se
        - name: FITNESSE_ADMIN_APP_TOKEN
          value: 29c30232-d514-4559-b60b-6de47175c1df
        - name: FITNESSE_USER_LOGIN_ID
          value: fitnesseUser@system.cora.uu.se
        - name: FITNESSE_USER_APP_TOKEN
          value: bd699488-f9d1-419d-a79d-9fa8a0f3bb9d
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

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-fitnesse
spec:
  selector:
    app: {{ .Values.system.name }}-fitnesse
  ports:
    - protocol: TCP
      port: 8090
      targetPort: 8090
{{- end }}
{{- end }}