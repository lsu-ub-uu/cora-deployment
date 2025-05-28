{{- define "cora.serveralias" -}}
apiVersion: v1
kind: Service
metadata:
  name: postgresql
spec:
  type: ClusterIP
  ports:
    - port: 5432
      targetPort: 5432
      protocol: TCP
      name: tcp
  selector:
    app: {{ .Values.system.name }}-postgresql
---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
spec:
  type: ClusterIP
  ports:
    - port: 5672
      targetPort: 5672
      protocol: TCP
      name: tcp
  selector:
    app: {{ .Values.system.name }}-rabbitmq
{{- end }}