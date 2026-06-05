{{- define "cora.fedora" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.system.name }}-fedora-deployment
  labels:
    app: {{ .Values.system.name }}-fedora
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .Values.system.name }}-fedora
  template:
    metadata:
      labels:
        app: {{ .Values.system.name }}-fedora
    spec:
      containers:
      - name: {{ .Values.system.name }}-fedora
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.fedora }}
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: {{ .Values.system.name }}-postgresql
        - name: POSTGRES_DB
          value: {{ .Values.system.name }}
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: {{ .Values.system.name }}-secret
              key: POSTGRES_USER
        volumeMounts:
        - mountPath: "/usr/local/tomcat/fcrepo-home/data/ocfl-root"
          name: archive-read-write

      # NFS sidecar container
      - name: {{ .Values.system.name }}-nfs
        image: {{ .Values.cora.dockerRepository.url }}{{ .Values.docker.nfs }}
        securityContext:
          privileged: true
        ports:
        - containerPort: 2049
          name: nfs
          protocol: TCP
        volumeMounts:
        - name: nfs-exports-config
          mountPath: /etc/ganesha
          readOnly: true
        - mountPath: "/archive-read-only"
          name: archive-read-write

      volumes:
        - name: archive-read-write
          persistentVolumeClaim:
            claimName: {{ .Values.system.name }}-archive-read-write-volume-claim

        - name: nfs-exports-config
          configMap:
            name: {{ .Values.system.name }}-nfs

      {{- if .Values.cora.dockerRepository.useImagePullSecrets }}
      imagePullSecrets:
      - name: {{ .Values.cora.dockerRepository.imagePullSecrets }}
      {{- end }}

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-fedora
spec:
  selector:
    app: {{ .Values.system.name }}-fedora
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080

---

apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.system.name }}-nfs
spec:
  selector:
#    app: {{ .Values.system.name }}-nfs
    app: {{ .Values.system.name }}-fedora
  ports:
  - name: nfs
    port: 2049
    targetPort: 2049
    protocol: TCP
  type: ClusterIP
  
---

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.system.name }}-nfs
data:
  ganesha.conf: |
    NFS_CORE_PARAM {
      Protocols = 4;
      Enable_UDP = false;
      Allow_Set_Io_Flusher_Fail = true;
      Nb_Worker = 128;
    }
    NFSV4 {
      Only_Numeric_Owners = true;
    }
    CacheInode {
      Attr_Expiration_Time = 60;
      Dir_Expiration_Time = 60;
      Cache_FDs = true;
    }
     %include /etc/ganesha/archive_read_only.conf
  archive_read_only.conf: |
    EXPORT {
      Export_Id = 11;
      Path = "/archive-read-only";
      Pseudo = "/archive-read-only";
      Access_Type = RO;
      Squash = No_Root_Squash;
      FSAL {
        Name = VFS;
      }
    }
    
    

{{- end }}