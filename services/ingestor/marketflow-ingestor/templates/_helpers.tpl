{{/*
Return the fully qualified app name.
*/}}
{{- define "marketflow-ingestor.fullname" -}}
{{- if .Chart.Name }}
{{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
marketflow-ingestor
{{- end -}}
{{- end }}
