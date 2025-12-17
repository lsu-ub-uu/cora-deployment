{{- define "cora.binaryconverter-service-account" -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: binaryconverter-job-sa
#  namespace: systemone

---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: binaryconverter-secret-writer
#  namespace: systemone
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs:
    - get
    - create

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: binaryconverter-secret-writer-binding
#  namespace: systemone
subjects:
- kind: ServiceAccount
  name: binaryconverter-job-sa
roleRef:
  kind: Role
  name: binaryconverter-secret-writer
  apiGroup: rbac.authorization.k8s.io
  
---
{{- end }}