{{- define "cora.binaryconverter" -}}

{{- $deploymentValues1 := dict "binaryConverter" (dict "subName" "smallimage" "queueName" "smallImageConverterQueue") }}
{{- $_ := set .Values "binaryConverter" $deploymentValues1.binaryConverter }}
{{ include "cora-binaryconverter.deployment" .}}

{{- $deploymentValues1 := dict "binaryConverter" (dict "subName" "jp2" "queueName" "jp2ConverterQueue") }}
{{- $_ := set .Values "binaryConverter" $deploymentValues1.binaryConverter }}
{{ include "cora-binaryconverter.deployment" .}}

{{- $deploymentValues1 := dict "binaryConverter" (dict "subName" "pdf" "queueName" "pdfConverterQueue") }}
{{- $_ := set .Values "binaryConverter" $deploymentValues1.binaryConverter }}
{{ include "cora-binaryconverter.deployment" .}}

{{- end }}