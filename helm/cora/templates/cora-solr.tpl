{{- define "cora.solr" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.system.name }}-solr-deployment
  labels:
    app: {{ .Values.system.name }}-solr
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-solr
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-solr
    spec:
      initContainers:
      - name: {{ .Values.system.name }}-solr-configurator
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.solr }}
        command: ["/bin/sh", "-c"]
        args:
          - |
            set -e
            
            SOURCE_CONFIG="/opt/solr/server/solr/configsets/coradefaultcore/conf"
            TARGET_CONFIG="/var/solr/data/coracore"
            
            if [ -d "$TARGET_CONFIG" ]; then
              echo "Existing core detected, syncing config"
              cp -r "$SOURCE_CONFIG" "$TARGET_CONFIG"
            else
              echo "Core does not exist yet, skipping sync so solr-precreate can create it"
            fi
        volumeMounts:
        - mountPath: "/var/solr/data"
          name: index-read-write
      containers:
      - name: {{ .Values.system.name }}-solr
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.solr }}
        ports:
        - containerPort: 8983
        args: ["solr-precreate", "coracore", "/opt/solr/server/solr/configsets/coradefaultcore"]
        volumeMounts:
        - mountPath: "/var/solr/data"
          name: index-read-write
      securityContext:
        runAsUser: 8983
        runAsGroup: 8983
        fsGroup: 8983
        fsGroupChangePolicy: "OnRootMismatch"
      volumes:
        - name: index-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-index-read-write-volume-claim
      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: solr
spec:
  selector:
    app: {{ .Values.system.name }}-solr
  ports:
    - protocol: TCP
      port: 8983
      targetPort: 8983
{{- end }}