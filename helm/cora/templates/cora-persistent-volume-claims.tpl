{{- define "cora.persistentVolumeClaims" -}}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-postgres-volume-claim
  labels:
    app: {{ .Values.system.name }}-postgres
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-archive-read-write-volume-claim
  labels:
    app: {{ .Values.system.name }}-archive
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-archive-read-only-volume-claim
  labels:
    app: {{ .Values.system.name }}-archive-read-only-volume
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 20Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-converted-files-read-write-volume-claim
  labels:
    app: {{ .Values.system.name }}-converted-files
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-converted-files-read-only-volume-claim
  labels:
    app: {{ .Values.system.name }}-converted-files-read-only-volume
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 20Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Values.system.name }}-{{ .Values.shibboleth.domain }}-credentials-read-only-volume-claim
  labels:
    app: {{ .Values.system.name }}-{{ .Values.shibboleth.domain }}-credentials-read-only-volume
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 20Gi

---
{{- end }}