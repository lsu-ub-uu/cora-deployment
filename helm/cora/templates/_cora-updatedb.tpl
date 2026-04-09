{{- define "cora.initContainer.waitForDbAndUpdatedbVersion" -}}
- name: init-wait-for-db-and-updatedb
  image: postgres:18-alpine
  env:
    - name: PGHOST
      value: {{ .Values.system.name }}-postgresql
    - name: PGPORT
      value: "5432"
    - name: PGDATABASE
      value: {{ .Values.system.name }}
    - name: PGUSER
      valueFrom:
        secretKeyRef:
          name: {{ .Values.system.name }}-secret
          key: POSTGRES_USER
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Values.system.name }}-secret
          key: POSTGRES_PASSWORD
    - name: applicationVersion
      value: {{ .Chart.AppVersion }}
  command:
    - sh
    - -c
    - |
      set -e
      until pg_isready; do echo waiting for database; sleep 2; done
      until psql -tAc "select value from cora_meta where key='updatedb_version'" | grep -qx "$applicationVersion"; do
        echo "waiting for updatedb_version=$applicationVersion"
        sleep 2
      done
{{- end -}}