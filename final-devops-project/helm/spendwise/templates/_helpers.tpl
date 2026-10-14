{{- define "spendwise.labels" -}}
app.kubernetes.io/part-of: spendwise
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{- define "spendwise.backend.name" -}}{{ .Release.Name }}-backend{{- end -}}
{{- define "spendwise.frontend.name" -}}{{ .Release.Name }}-frontend{{- end -}}
{{- define "spendwise.db.name" -}}{{ .Release.Name }}-postgres{{- end -}}

{{- define "spendwise.db.secretName" -}}
{{- if .Values.database.existingSecret -}}{{ .Values.database.existingSecret }}{{- else -}}{{ .Release.Name }}-db{{- end -}}
{{- end -}}

{{- define "spendwise.image" -}}
{{- $tag := required (printf "%s.image.tag is required" .component) .image.tag -}}
{{ printf "%s:%s" .image.repository $tag }}
{{- end -}}
